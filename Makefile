
SHELL := /bin/bash
SRC_FILES := $(shell find Sources -name '*.swift')

Steem.xcodeproj:
	swift package generate-xcodeproj

docs: Steem.xcodeproj $(SRC_FILES)
	@command -v jazzy >/dev/null || (echo "doc generator missing, run: [sudo] gem install jazzy"; exit 1)
	jazzy --min-acl public \
		-g https://github.com/steemit/swift-steem \
		-a "Steemit Inc." \
		-u https://steem.com \
		&& touch docs

.gh-pages:
	git clone `git config --get remote.origin.url` -b gh-pages .gh-pages

.PHONY: update-docs
update-docs: .gh-pages docs
	cp -r docs/* .gh-pages/
	cd .gh-pages && git add . && git commit -m "Update docs [ci skip]" && git push

.PHONY: clean
clean:
	rm -rf .gh-pages/ docs/
	rm -rf .build/ build/
