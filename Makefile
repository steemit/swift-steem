
SHELL := /bin/bash
SRC_FILES := $(shell find Sources -name '*.swift')

Steem.xcodeproj:
	swift package generate-xcodeproj

docs: Steem.xcodeproj $(SRC_FILES) README.md
	@command -v jazzy >/dev/null || (echo "doc generator missing, run: [sudo] gem install jazzy"; exit 1)
	jazzy --min-acl public \
		-g https://github.com/steemit/swift-steem \
		-a "Steemit Inc." \
		-u https://steem.com \
		&& touch docs

.PHONY: format
format:
	@command -v swiftformat >/dev/null || (echo "formatter missing, run: brew install swiftformat"; exit 1)
	swiftformat \
		--self insert \
		--comments ignore \
		--disable redundantReturn \
		Package.swift Tests/ Sources/

.gh-pages:
	git clone `git config --get remote.origin.url` -b gh-pages .gh-pages

.PHONY: update-docs
update-docs: .gh-pages docs
	cp -r docs/* .gh-pages/
	cd .gh-pages && git add . && git commit -m "Update docs [ci skip]" && git push

.PHONY: clean
clean:
	rm -rf Steem.xcodeproj
	rm -rf .gh-pages/ docs/
	rm -rf .build/ build/
