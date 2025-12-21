package domain

import "context"

type TodoRepository interface {
	Create(ctx context.Context, todo Todo) (Todo, error)
	GetByID(ctx context.Context, id string) (Todo, error)
	List(ctx context.Context) ([]Todo, error)
	Update(ctx context.Context, todo Todo) (Todo, error)
	Delete(ctx context.Context, id string) error
}
