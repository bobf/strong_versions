# frozen_string_literal: true

module StrongVersions
  class Dependencies
    def initialize(dependencies)
      @dependencies = dependencies.map do |raw_dependency|
        Dependency.new(raw_dependency)
      end
      @invalid_gems = []
    end

    def validate!(options = {})
      return if validate(options)

      # We must raise an error that Bundler recognises otherwise it prints a
      # huge amount of output. `Bundler::GemspecError` just outputs the error
      # message we set in red.
      raise Bundler::GemspecError,
            "StrongVersions expectations not met: #{error_message}"
    end

    def validate(options = {})
      @dependencies.each do |dependency|
        next if options.fetch(:except, []).include?(dependency.name)
        next if dependency.valid?

        @invalid_gems.push(dependency) unless dependency.valid?
      end
      @invalid_gems.empty?
    end

    def error_message
      @invalid_gems.map do |invalid_gem|
        "#{invalid_gem.name}: #{invalid_gem.errors}"
      end.join(', ')
    end
  end
end
