package main

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

func main() {
	// 1. Configure the AWS SDK to point to the local DynamoDB
	//    We use "dummy" credentials because local DynamoDB doesn't validate signatures,
	//    but the SDK requires them to be present.
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider("dummy", "dummy", "")),
	)
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	// 2. Create the DynamoDB client (override endpoint using Endpoint Resolver v2)
	svc := dynamodb.NewFromConfig(cfg, func(o *dynamodb.Options) {
		// BaseEndpoint keeps default resolver behavior while swapping the host.
		o.BaseEndpoint = aws.String("http://localhost:8000")
	})

	// 3. Define a table name
	tableName := "Users"

	// 4. Create the table (if it doesn't exist)
	fmt.Printf("Checking if table '%s' exists...\n", tableName)
	_, err = svc.DescribeTable(context.TODO(), &dynamodb.DescribeTableInput{
		TableName: aws.String(tableName),
	})

	if err != nil {
		// If the table is not found, we create it
		// Note: handling specific error types (ResourceNotFoundException) is better in production
		fmt.Printf("Table not found. Creating table '%s'...\n", tableName)
		_, err = svc.CreateTable(context.TODO(), &dynamodb.CreateTableInput{
			TableName: aws.String(tableName),
			AttributeDefinitions: []types.AttributeDefinition{
				{
					AttributeName: aws.String("ID"),
					AttributeType: types.ScalarAttributeTypeS, // String
				},
			},
			KeySchema: []types.KeySchemaElement{
				{
					AttributeName: aws.String("ID"),
					KeyType:       types.KeyTypeHash, // Partition Key
				},
			},
			ProvisionedThroughput: &types.ProvisionedThroughput{
				ReadCapacityUnits:  aws.Int64(5),
				WriteCapacityUnits: aws.Int64(5),
			},
		})
		if err != nil {
			log.Fatalf("Got error calling CreateTable: %s", err)
		}
		fmt.Println("Table created successfully.")
	} else {
		fmt.Println("Table already exists.")
	}

	// 5. Put an Item
	fmt.Println("Putting an item...")
	_, err = svc.PutItem(context.TODO(), &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item: map[string]types.AttributeValue{
			"ID":    &types.AttributeValueMemberS{Value: "123"},
			"Name":  &types.AttributeValueMemberS{Value: "Alice"},
			"Email": &types.AttributeValueMemberS{Value: "alice@example.com"},
		},
	})
	if err != nil {
		log.Fatalf("Got error calling PutItem: %s", err)
	}
	fmt.Println("Successfully added item.")

	// 6. Get the Item back
	fmt.Println("Getting the item back...")
	result, err := svc.GetItem(context.TODO(), &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]types.AttributeValue{
			"ID": &types.AttributeValueMemberS{Value: "123"},
		},
	})
	if err != nil {
		log.Fatalf("Got error calling GetItem: %s", err)
	}

	if result.Item == nil {
		fmt.Println("Could not find item '123'")
		return
	}

	// Helper to safely print values
	var name, email string
	if v, ok := result.Item["Name"].(*types.AttributeValueMemberS); ok {
		name = v.Value
	}
	if v, ok := result.Item["Email"].(*types.AttributeValueMemberS); ok {
		email = v.Value
	}

	fmt.Printf("Found item: ID=123, Name=%s, Email=%s\n", name, email)
}
