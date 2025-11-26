package main

import (
	"context"
	"log"
	"time"

	"example/database"
	"example/models"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/contrib/v3/swaggerui"
	"go.mongodb.org/mongo-driver/bson"
	_ "example/docs" // Import generated docs
)

// @title Example Fiber API with MongoDB
// @version 1.0
// @description This is a sample API connecting to MongoDB using Fiber.
// @host localhost:3000
// @BasePath /
func main() {
	// Connect to MongoDB
	if err := database.Connect(); err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}

	app := fiber.New()

	// Swagger route
	app.Get("/swagger/*", swaggerui.New(swaggerui.Config{
		Title: "Example API Docs",
	}))

	// Routes
	app.Get("/", HealthCheck)
	app.Get("/users", GetUsers)
	app.Post("/users", CreateUser)

	log.Fatal(app.Listen(":3000"))
}

// HealthCheck godoc
// @Summary Show the status of server.
// @Description get the status of server.
// @Tags root
// @Accept */*
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router / [get]
func HealthCheck(c fiber.Ctx) error {
	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Server is running!",
	})
}

// GetUsers godoc
// @Summary Get all users
// @Description Get a list of all users
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {array} models.User
// @Failure 500 {object} map[string]interface{}
// @Router /users [get]
func GetUsers(c fiber.Ctx) error {
	collection := database.DB.Collection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// bson.M{} is an empty filter (select all)
	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	defer cursor.Close(ctx)

	var users []models.User = make([]models.User, 0)
	if err := cursor.All(ctx, &users); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(users)
}

// CreateUser godoc
// @Summary Create a user
// @Description Create a new user
// @Tags users
// @Accept json
// @Produce json
// @Param user body models.User true "User"
// @Success 201 {object} models.User
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /users [post]
func CreateUser(c fiber.Ctx) error {
	collection := database.DB.Collection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	user := new(models.User)
	if err := c.Bind().Body(user); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid body"})
	}

	result, err := collection.InsertOne(ctx, user)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(201).JSON(fiber.Map{
		"result": result,
		"user":   user,
	})
}