package httpapi

import "github.com/gofiber/fiber/v2"

func RegisterRoutes(app *fiber.App, todoHandler *TodoHandler) {
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendString("ok")
	})

	app.Get("/todos", todoHandler.List)
	app.Get("/todos/:id", todoHandler.Get)
	app.Post("/todos", todoHandler.Create)
	app.Put("/todos/:id", todoHandler.Update)
	app.Delete("/todos/:id", todoHandler.Delete)
}
