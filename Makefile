.PHONY: test
test:
	bin/rspec
	bin/rubocop
	bundle exec bin/strong_versions
