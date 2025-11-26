package database

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var DB *mongo.Database

func Connect() error {
	// MongoDB connection string
	uri := os.Getenv("MONGO_URI")

	// If MONGO_URI is not set, try constructing it from individual vars (Secrets Manager pattern)
	if uri == "" {
		user := os.Getenv("DB_USER")
		password := os.Getenv("DB_PASSWORD")
		host := os.Getenv("DB_HOST")
		port := os.Getenv("DB_PORT")

		if user != "" && password != "" && host != "" {
			if port == "" {
				port = "27017"
			}
			// Construct URI for DocumentDB (TLS enabled by default)
			// We append the options typically required for AWS DocumentDB
			uri = fmt.Sprintf("mongodb://%s:%s@%s:%s/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false",
				user, password, host, port)
		} else {
			// Fallback for local development
			uri = "mongodb://root:examplepassword@localhost:27017"
		}
	}

	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(context.Background(), clientOptions)
	if err != nil {
		return fmt.Errorf("failed to connect to mongo: %v", err)
	}

	// Verify connection
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := client.Ping(ctx, nil); err != nil {
		return fmt.Errorf("failed to ping mongo: %v", err)
	}

	DB = client.Database("example_db")
	log.Println("Connected to MongoDB!")
	return nil
}
