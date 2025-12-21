package domain

import (
	"errors"
	"time"
)

var ErrTodoNotFound = errors.New("todo not found")

type Todo struct {
	ID        string
	Title     string
	Completed bool
	CreatedAt time.Time
}

func (t Todo) Validate() error {
	if t.Title == "" {
		return errors.New("title is required")
	}

	return nil
}
