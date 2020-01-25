.PHONY: test
test:
	@bin/rspec
	@bundle exec bin/strong_versions
	@bin/rubocop
	@bin/rubocop bin/strong_versions
