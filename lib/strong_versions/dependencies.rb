# frozen_string_literal: true

module StrongVersions
  class Dependencies
    def initialize(dependencies)
      @dependencies = dependencies.map do |raw_dependency|
        Dependency.new(raw_dependency)
      end
      @invalid_gems = []
      @terminal = Terminal.new
    end

    def validate!(options = {})
      return success if validate(options)

      on_failure = options.fetch(:on_failure, 'raise')
      case on_failure
      when 'raise'
        raise_failure
      when 'warn'
        warn_failure
      end

      false
    end

    def validate(options = {})
      @dependencies.each do |dependency|
        next if options.fetch(:except).include?(dependency.name)
        next if dependency.valid?

        @invalid_gems.push(dependency) unless dependency.valid?
      end
      @invalid_gems.empty?
    end

    private

    def success
      @terminal.success(
        I18n.t('strong_versions.success', count: @dependencies.size)
      )
    end

    def raise_failure
      warn_failure
      # We must raise an error that Bundler recognises otherwise it prints a
      # huge amount of output. `Bundler::GemspecError` just outputs the error
      # message we set in red.
      raise Bundler::GemspecError, 'StrongVersions failure'
    end

    def warn_failure
      @terminal.warn("\nStrongVersions expectations not met:\n")
      @invalid_gems.each do |gem|
        @terminal.output_errors(gem.name, gem.errors)
      end
      @terminal.puts("\n")
    end

    def raise_unknown(on_failure)
      raise Bundler::Error,
            I18n.t(
              'strong_versions.errors.unknown_on_failure',
              on_failure: on_failure
            )
    end
  end
end
