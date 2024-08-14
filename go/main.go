package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"sort"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
)

type Golings []Exercise
type Exercise struct {
	No       int       `dynamodbav:"no"`
	Notified time.Time `dynamodbav:"notified"`
	Name     string    `dynamodbav:"name"`
	Path     string    `dynamodbav:"path"`
}

func main() {
	fmt.Println("Hello, World!")
	fmt.Println(time.Now())
	table := os.Getenv("TABLE_NAME")

	db, err := newDB()
	if err != nil {
		slog.Error(fmt.Sprintf("failed to create dynamodb client: %v", err))
		return
	}

	golings, err := getMaster(db, table)
	if err != nil {
		slog.Error(fmt.Sprintf("failed to get master: %v", err))
		return
	}

	nextExercise := NextExercise(golings)
	fmt.Println(nextExercise)

}

func newDB() (*dynamodb.Client, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("ap-northeast-1"))
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
		return golings[i].Notified.Before(golings[j].Notified)
	})
	return golings[0]
}
