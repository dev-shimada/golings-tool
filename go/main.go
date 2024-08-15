package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/tenntenn/goplayground"
	"golang.org/x/tools/txtar"
)

type MyEvent struct{}

type Golings []Exercise
type Exercise struct {
	No       int    `dynamodbav:"no"`
	Notified string `dynamodbav:"notified"`
	Name     string `dynamodbav:"name"`
	Path     string `dynamodbav:"path"`
}

func main() {
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event *MyEvent) (string, error) {
	fmt.Println("Hello, World!")
	fmt.Println(time.Now().Local())

	// get env
	table, webhook, err := requireEnv()
	if err != nil {
		slog.Error(fmt.Sprintf("failed to get env: %v", err))
		return "", err
	}

	// dynamodb client
	db, err := newDB()
	if err != nil {
		slog.Error(fmt.Sprintf("failed to create dynamodb client: %v", err))
		return "", err
	}

	// scan table
	golings, err := getMaster(db, table)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to get master: %v", err))
		return "", err
	}

	// get next exercise
	nextExercise := NextExercise(golings)

	// upload to go playground
	shareURL, err := Upload(nextExercise.Path)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to upload: %v", err))
		return "", err
	}

	// notify to slack
	err = ToSlack(webhook, shareURL, nextExercise)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to notify: %v", err))
		return "", err
	}

	// update notified
	err = UpdateNotified(db, table, nextExercise)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to update notified: %v", err))
		return "", err
	}

	return "ok", nil
}

func requireEnv() (string, string, error) {
	aws_session_token := os.Getenv("AWS_SESSION_TOKEN")
	req, err := http.NewRequest(http.MethodGet, "http://localhost:2773/systemsmanager/parameters/get?name=%2Fgolings-tool%2FWEBHOOK_URL&withDecryption=true", nil)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to create request: %v", err))
		return "", "", err
	}

	req.Header.Set("X-Aws-Parameters-Secrets-Token", aws_session_token)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to send request: %v", err))
		return "", "", err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to read body: %v", err))
		return "", "", err
	}

	type parameter struct {
		Parameter struct {
			Value string `json:"Value"`
		} `json:"Parameter"`
	}
	var p parameter
	err = json.Unmarshal(body, &p)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to unmarshal body: %v", err))
		return "", "", err
	}

	webhook := p.Parameter.Value
	table := os.Getenv("TABLE_NAME")

	return table, webhook, nil
}

func newDB() (*dynamodb.Client, error) {
	region := os.Getenv("AWS_REGION")
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(region))
	if err != nil {
		slog.Error(fmt.Sprintf("failed to load configuration: %v", err))
		return nil, err
	}
	client := dynamodb.NewFromConfig(cfg)
	return client, nil
}

func getMaster(db *dynamodb.Client, table string) (Golings, error) {
	res, err := db.Scan(context.TODO(), &dynamodb.ScanInput{TableName: aws.String(table)})
	if err != nil {
		slog.Error(fmt.Sprintf("failed to scan table: %v", err))
		return Golings{}, err
	}
	var golings Golings

	err = attributevalue.UnmarshalListOfMaps(res.Items, &golings)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to unmarshal items: %v", err))
		return Golings{}, err
	}

	return golings, nil
}

func NextExercise(golings Golings) Exercise {
	// sort by notified
	sort.Slice(golings, func(i, j int) bool {
		return golings[i].No < golings[j].No
	})
	sort.SliceStable(golings, func(i, j int) bool {
		it, _ := time.Parse(time.RFC3339, golings[i].Notified)
		ij, _ := time.Parse(time.RFC3339, golings[j].Notified)
		return it.Before(ij)
	})
	return golings[0]
}

func Upload(paths string) (string, error) {
	src, err := toReader("golings-main/" + paths)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to create reader: %v", err))
		return "", err
	}

	var backend goplayground.Backend

	client := &goplayground.Client{
		Backend: backend,
	}
	shareURL, err := client.Share(src)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to share: %v", err))
		return "", err
	}
	return shareURL.String(), nil
}

func toReader(paths ...string) (io.Reader, error) {
	if len(paths) == 0 {
		return os.Stdin, nil
	}

	if len(paths) == 1 {
		data, err := os.ReadFile(paths[0])
		if err != nil {
			return nil, fmt.Errorf("cannot read file (%s): %w", paths[0], err)
		}
		return bytes.NewReader(data), nil
	}

	var a txtar.Archive
	for _, p := range paths {
		data, err := os.ReadFile(p)
		if err != nil {
			return nil, fmt.Errorf("cannot read file (%s): %w", p, err)
		}
		a.Files = append(a.Files, txtar.File{
			Name: filepath.ToSlash(filepath.Clean(p)),
			Data: data,
		})
	}

	return bytes.NewReader(txtar.Format(&a)), nil
}

func ToSlack(webhook string, shareUrl string, exercise Exercise) error {
	type text struct {
		Type string `json:"type"`
		Text string `json:"text"`
	}
	type block struct {
		Type string `json:"type"`
		Text text   `json:"text"`
	}
	type message struct {
		Blocks []block `json:"blocks"`
	}
	// slack通知
	t1 := text{
		Type: "mrkdwn",
		Text: fmt.Sprintf("@channel \n :gopher: *今週のGolings:* :gopher: \n No%v. %s", exercise.No, exercise.Name),
	}
	b1 := block{
		Type: "section",
		Text: t1,
	}
	t2 := text{
		Type: "mrkdwn",
		Text: fmt.Sprintf("URL: %s", shareUrl),
	}
	b2 := block{
		Type: "section",
		Text: t2,
	}
	msg := message{
		Blocks: []block{b1, b2},
	}
	messageJSON, err := json.Marshal(msg)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to marshal message: %v", err))
		return err
	}
	// post
	req, err := http.NewRequest(http.MethodPost, webhook, bytes.NewBuffer(messageJSON))
	if err != nil {
		slog.Error(fmt.Sprintf("failed to create request: %v", err))
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	_, err = client.Do(req)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to send request: %v", err))
		return err
	}
	return nil
}

func UpdateNotified(db *dynamodb.Client, table string, exercise Exercise) error {
	now := time.Now().Local().Format(time.RFC3339)
	input := &dynamodb.UpdateItemInput{
		AttributeUpdates: map[string]types.AttributeValueUpdate{
			"notified": {
				Action: types.AttributeActionPut,
				Value:  &types.AttributeValueMemberS{Value: now},
			},
		},
		Key: map[string]types.AttributeValue{
			"no": &types.AttributeValueMemberN{Value: fmt.Sprintf("%d", exercise.No)},
		},
		TableName: aws.String(table),
	}
	_, err := db.UpdateItem(context.TODO(), input)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to update item: %v", err))
		return err
	}
	return nil
}
