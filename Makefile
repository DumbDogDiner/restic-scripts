all: fmt build

fmt:
	@echo "==> Formatting code..."
	@go fmt ./...

build:
	# someone please fix the broken line wrapping
	@echo "==> Building Go code..."
	# inject compile-time variables
	@go build -o bin/rscripts-amd64 -ldflags \
	 	"-X github.com/dumbdogdiner/rscripts/internal/app/constants.GitHash=$(shell git log -1 --pretty=format:"%H") \
		-X github.com/dumbdogdiner/rscripts/internal/app/constants.GitTag=1.2.3 \
		-X github.com/dumbdogdiner/rscripts/internal/app/constants.RepositoryUrl=https://api.github.com/repos/DumbDogDiner/restic-scripts" \
		cmd/rscripts/main.go

tool:
	@go tool nm -n ./bin/rscripts-amd64
