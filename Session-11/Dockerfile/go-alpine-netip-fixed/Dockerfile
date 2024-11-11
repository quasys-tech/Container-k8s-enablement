FROM golang:1.23.3-alpine3.20 AS build

# Build binary from go source
WORKDIR /go/src/app
COPY ./src/* .
RUN go mod download
RUN GOOS=linux go build -o /go/bin/app -v .


FROM golang:1.23.3-alpine3.20
# Copy binary from build step
COPY --from=build /go/bin/app /go/bin/app

# Set startup options
EXPOSE 8080
ENTRYPOINT [ "/go/bin/app" ]
