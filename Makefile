all: deps fmt build

deps:
	@echo "==> Cleaning up dependencies..."
	go mod tidy
	go mod vendor

fmt:
	@echo "==> Formatting code..."
	go fmt ./...

build:
	# someone please fix the broken line wrapping
	@echo "==> Building Go code..."
	# inject compile-time variables
	# will use temporary git tag
	go build -o bin/rscripts-amd64 -ldflags \
	 	"-X github.com/dumbdogdiner/rscripts/internal/app/constants.GitHash=$(shell git log -1 --pretty=format:"%H") \
		-X github.com/dumbdogdiner/rscripts/internal/app/constants.GitTag=1.2.3 \
		-X github.com/dumbdogdiner/rscripts/internal/app/constants.RepositoryUrl=https://api.github.com/repos/DumbDogDiner/restic-scripts" \
		cmd/rscripts/main.go
	@echo "Done."

tool:
	@go tool nm -n ./bin/rscripts-amd64
