package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"

	"rest-api/infrastructure/memory"
	httpapi "rest-api/interfaces/http"
	"rest-api/usecase"
)

func main() {
	app := fiber.New()

	todoRepo := memory.NewTodoRepository()
	todoUsecase := usecase.NewTodoUsecase(todoRepo)
	todoHandler := httpapi.NewTodoHandler(todoUsecase)

	httpapi.RegisterRoutes(app, todoHandler)

	port := getPort()
	log.Printf("starting server on :%s", port)

	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("server stopped: %v", err)
	}
}

func getPort() string {
	if port := os.Getenv("PORT"); port != "" {
		return port
	}
	return "3000"
}
