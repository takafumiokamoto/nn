package memory

import (
	"context"
	"strconv"
	"sync"
	"time"

	"rest-api/domain"
)

type TodoRepository struct {
	mu     sync.RWMutex
	items  map[string]domain.Todo
	nextID int64
}

func NewTodoRepository() *TodoRepository {
	return &TodoRepository{
		items: make(map[string]domain.Todo),
	}
}

func (r *TodoRepository) Create(ctx context.Context, todo domain.Todo) (domain.Todo, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if todo.ID == "" {
		r.nextID++
		todo.ID = strconv.FormatInt(r.nextID, 10)
	}

	if todo.CreatedAt.IsZero() {
		todo.CreatedAt = time.Now()
	}

	r.items[todo.ID] = todo
	return todo, nil
}

func (r *TodoRepository) GetByID(ctx context.Context, id string) (domain.Todo, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	todo, ok := r.items[id]
	if !ok {
		return domain.Todo{}, domain.ErrTodoNotFound
	}

	return todo, nil
}

func (r *TodoRepository) List(ctx context.Context) ([]domain.Todo, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	todos := make([]domain.Todo, 0, len(r.items))
	for _, todo := range r.items {
		todos = append(todos, todo)
	}

	return todos, nil
}

func (r *TodoRepository) Update(ctx context.Context, todo domain.Todo) (domain.Todo, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, ok := r.items[todo.ID]; !ok {
		return domain.Todo{}, domain.ErrTodoNotFound
	}

	r.items[todo.ID] = todo
	return todo, nil
}

func (r *TodoRepository) Delete(ctx context.Context, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, ok := r.items[id]; !ok {
		return domain.ErrTodoNotFound
	}

	delete(r.items, id)
	return nil
}
