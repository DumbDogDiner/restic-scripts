all: fmt build

fmt:
	@echo "==> Formatting code..."
	@sh -c "'$(CURDIR)/scripts/format.sh'"

build:
	# someone please fix the broken line wrapping
	@echo "==> Building Go code..."
	@go build -o bin/rscripts-amd64 -ldflags "-X github.com/dumbdogdiner/rscripts/internal/app/rscripts.GitCommit=$(shell git log -1 --pretty=format:"%H")" cmd/rscripts/main.go
