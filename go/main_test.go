package main_test

import (
	"testing"
	"time"

	main "github.com/dev-shimada/golings-tool"
	"github.com/google/go-cmp/cmp"
)

func TestNextExercise(t *testing.T) {
	t.Run("test", func(t *testing.T) {
		// test code
		var t0 = time.Date(1, 1, 1, 0, 0, 0, 0, time.UTC)
		var t1 = time.Date(2024, 1, 1, 0, 0, 0, 1, time.Local)
		var t2 = time.Date(2024, 1, 1, 0, 0, 0, 2, time.Local)
		var test = main.Golings{
			main.Exercise{No: 1, Notified: t0, Name: "test1", Path: "path1"},
			main.Exercise{No: 2, Notified: t1, Name: "test2", Path: "path2"},
			main.Exercise{No: 3, Notified: t2, Name: "test3", Path: "path3"},
		}

		got := main.NextExercise(test)
		want := main.Exercise{No: 1, Notified: t0, Name: "test1", Path: "path1"}
		if !cmp.Equal(got, want) {
			t.Errorf("diff: %v", cmp.Diff(got, want))
		}
	})
}
