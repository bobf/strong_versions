.PHONY: test
test:
	@bundle exec rspec
	@bundle exec strong_versions
	@bundle exec rubocop
