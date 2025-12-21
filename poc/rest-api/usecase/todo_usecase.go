package usecase

import (
	"context"
	"time"

	"rest-api/domain"
)

type TodoUsecase struct {
	repo domain.TodoRepository
}

func NewTodoUsecase(repo domain.TodoRepository) *TodoUsecase {
	return &TodoUsecase{repo: repo}
}

func (uc *TodoUsecase) Create(ctx context.Context, title string) (domain.Todo, error) {
	todo := domain.Todo{
		Title:     title,
		Completed: false,
		CreatedAt: time.Now(),
	}

	if err := todo.Validate(); err != nil {
		return domain.Todo{}, err
	}

	return uc.repo.Create(ctx, todo)
}

func (uc *TodoUsecase) Get(ctx context.Context, id string) (domain.Todo, error) {
	return uc.repo.GetByID(ctx, id)
}

func (uc *TodoUsecase) List(ctx context.Context) ([]domain.Todo, error) {
	return uc.repo.List(ctx)
}

func (uc *TodoUsecase) Update(ctx context.Context, id, title string, completed bool) (domain.Todo, error) {
	todo, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Todo{}, err
	}

	todo.Title = title
	todo.Completed = completed

	if err := todo.Validate(); err != nil {
		return domain.Todo{}, err
	}

	return uc.repo.Update(ctx, todo)
}

func (uc *TodoUsecase) Delete(ctx context.Context, id string) error {
	return uc.repo.Delete(ctx, id)
}
