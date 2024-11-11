# Stage 1: Build the Go binary
FROM golang:1.23.3-alpine3.20 AS build

# Set up build environment
WORKDIR /go/src/app
COPY ./src/* .

# Download Go modules and build the binary
RUN go mod download
RUN GOOS=linux go build -o /go/bin/app -v .

# Stage 2: Create a non-root user and copy the binary
FROM golang:1.23.3-alpine3.20

# Add a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create necessary directories and set appropriate permissions
WORKDIR /app
RUN chown -R appuser:appgroup /app

# Copy the built binary from the build stage
COPY --from=build /go/bin/app /app/app

# Expose the required port
EXPOSE 8080

# Switch to the non-root user
USER appuser

# Set the entry point
ENTRYPOINT [ "/app/app" ]
