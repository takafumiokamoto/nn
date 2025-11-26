# Start from the official Golang image
FROM golang:1.25.3-alpine

WORKDIR /app

# Copy go.mod and go.sum first to leverage cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Generate swagger docs just in case
RUN go install github.com/swaggo/swag/cmd/swag@latest
RUN swag init
# Move swagger.json to root as middleware expects it there by default
RUN cp docs/swagger.json .

# Download AWS DocumentDB CA Bundle
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem .

# Build the application
RUN go build -o app main.go

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["./app"]