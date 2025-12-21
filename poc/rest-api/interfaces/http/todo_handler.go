package httpapi

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"

	"rest-api/domain"
	"rest-api/usecase"
)

type TodoHandler struct {
	usecase *usecase.TodoUsecase
}

func NewTodoHandler(usecase *usecase.TodoUsecase) *TodoHandler {
	return &TodoHandler{usecase: usecase}
}

type CreateTodoRequest struct {
	Title string `json:"title"`
}

type UpdateTodoRequest struct {
	Title     string `json:"title"`
	Completed bool   `json:"completed"`
}

type TodoResponse struct {
	ID        string    `json:"id"`
	Title     string    `json:"title"`
	Completed bool      `json:"completed"`
	CreatedAt time.Time `json:"created_at"`
}

func (h *TodoHandler) Create(c *fiber.Ctx) error {
	var req CreateTodoRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}

	todo, err := h.usecase.Create(c.UserContext(), req.Title)
	if err != nil {
		return mapError(err)
	}

	return c.Status(fiber.StatusCreated).JSON(toResponse(todo))
}

func (h *TodoHandler) Get(c *fiber.Ctx) error {
	todo, err := h.usecase.Get(c.UserContext(), c.Params("id"))
	if err != nil {
		return mapError(err)
	}

	return c.JSON(toResponse(todo))
}

func (h *TodoHandler) List(c *fiber.Ctx) error {
	todos, err := h.usecase.List(c.UserContext())
	if err != nil {
		return mapError(err)
	}

	responses := make([]TodoResponse, 0, len(todos))
	for _, todo := range todos {
		responses = append(responses, toResponse(todo))
	}

	return c.JSON(responses)
}

func (h *TodoHandler) Update(c *fiber.Ctx) error {
	var req UpdateTodoRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}

	todo, err := h.usecase.Update(c.UserContext(), c.Params("id"), req.Title, req.Completed)
	if err != nil {
		return mapError(err)
	}

	return c.JSON(toResponse(todo))
}

func (h *TodoHandler) Delete(c *fiber.Ctx) error {
	if err := h.usecase.Delete(c.UserContext(), c.Params("id")); err != nil {
		return mapError(err)
	}

	return c.SendStatus(fiber.StatusNoContent)
}

func toResponse(todo domain.Todo) TodoResponse {
	return TodoResponse{
		ID:        todo.ID,
		Title:     todo.Title,
		Completed: todo.Completed,
		CreatedAt: todo.CreatedAt,
	}
}

func mapError(err error) error {
	switch {
	case errors.Is(err, domain.ErrTodoNotFound):
		return fiber.NewError(fiber.StatusNotFound, err.Error())
	default:
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}
}
