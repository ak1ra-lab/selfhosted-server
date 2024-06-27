
.PHONY: yamlfmt
yamlfmt:
	command yamlfmt 2>/dev/null || \
		go install github.com/google/yamlfmt/cmd/yamlfmt@latest

fmt: yamlfmt  ## reformat files
	yamlfmt .

clean:  ## clean up
	rm -rf ./bin
	git gc --aggressive

help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
		printf "\033[36m%-10s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)
.DEFAULT_GOAL=help
.PHONY=help
