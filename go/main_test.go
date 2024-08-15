package main_test

import (
	"os"
	"testing"
	"time"

	main "github.com/dev-shimada/golings-tool"
	"github.com/google/go-cmp/cmp"
)

func TestNextExercise(t *testing.T) {
	t.Run("test", func(t *testing.T) {
		// 日付が最も古い方が取得される
		var t1 = time.Date(2024, 1, 1, 1, 0, 0, 1, time.Local).Format(time.RFC3339)
		var t2 = time.Date(2024, 1, 1, 2, 0, 0, 2, time.Local).Format(time.RFC3339)
		var t3 = time.Date(2024, 1, 1, 3, 0, 0, 3, time.Local).Format(time.RFC3339)
		var test = main.Golings{
			main.Exercise{No: 1, Notified: t2, Name: "test1", Path: "path1"},
			main.Exercise{No: 2, Notified: t3, Name: "test2", Path: "path2"},
			main.Exercise{No: 3, Notified: t1, Name: "test3", Path: "path3"},
		}

		got := main.NextExercise(test)
		want := main.Exercise{No: 3, Notified: t1, Name: "test3", Path: "path3"}

		if !cmp.Equal(got, want) {
			t.Errorf("diff: %v", cmp.Diff(got, want))
		}
	})

	t.Run("test 0 notified", func(t *testing.T) {
		// 日付が0が取得される
		var t0 = time.Date(1, 1, 1, 0, 0, 0, 0, time.UTC).Format(time.RFC3339)
		var t1 = time.Date(2024, 1, 1, 0, 0, 0, 1, time.Local).Format(time.RFC3339)
		var t2 = time.Date(2024, 1, 1, 0, 0, 0, 2, time.Local).Format(time.RFC3339)
		var test = main.Golings{
			main.Exercise{No: 1, Notified: t1, Name: "test1", Path: "path1"},
			main.Exercise{No: 2, Notified: t0, Name: "test2", Path: "path2"},
			main.Exercise{No: 3, Notified: t2, Name: "test3", Path: "path3"},
		}

		got := main.NextExercise(test)
		want := main.Exercise{No: 2, Notified: t0, Name: "test2", Path: "path2"}

		if !cmp.Equal(got, want) {
			t.Errorf("diff: %v", cmp.Diff(got, want))
		}
	})

	t.Run("test same notified", func(t *testing.T) {
		// 同じ日付が複数ある場合(0を含む)はNoが最小のものが取得される
		var t0 = time.Date(1, 1, 1, 0, 0, 0, 0, time.UTC).Format(time.RFC3339)
		var t1 = time.Date(2024, 1, 1, 0, 0, 0, 1, time.Local).Format(time.RFC3339)
		var test = main.Golings{
			main.Exercise{No: 1, Notified: t1, Name: "test1", Path: "path1"},
			main.Exercise{No: 2, Notified: t0, Name: "test2", Path: "path2"},
			main.Exercise{No: 3, Notified: t0, Name: "test3", Path: "path3"},
		}

		got := main.NextExercise(test)
		want := main.Exercise{No: 2, Notified: t0, Name: "test2", Path: "path2"}

		if !cmp.Equal(got, want) {
			t.Errorf("diff: %v", cmp.Diff(got, want))
		}
	})
}

func TestUpload(t *testing.T) {
	t.Run("test", func(t *testing.T) {
		paths := "exercises/variables/variables1/main.go"
		got, err := main.Upload(paths)
		if err != nil {
			t.Errorf("failed to upload: %v", err)
		}
		if got == "" {
			t.Errorf("failed to upload: %v", got)
		}
		t.Logf("uploaded: %v", got)
	})
}

func TestToSlack(t *testing.T) {
	t.Run("test", func(t *testing.T) {
		webhook := os.Getenv("WEBHOOK_URL")
		shareUrl := "https://example.com"
		exercise := main.Exercise{No: 1, Notified: time.Now().Format(time.RFC3339), Name: "test", Path: "path"}

		err := main.ToSlack(webhook, shareUrl, exercise)

		if err != nil {
			t.Errorf("failed to notify: %v", err)
		}
	})
}
