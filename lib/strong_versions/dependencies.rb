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
      if validate(options)
        summary
        return true
      end

      raise_or_warn(options.fetch(:on_failure, 'raise'))
      summary
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

    def summary
      @terminal.summary(@dependencies.size, @invalid_gems.size)
    end

    def raise_or_warn(on_failure)
      case on_failure
      when 'raise'
        raise_failure
      when 'warn'
        warn_failure
      end
    end

    def raise_failure
      warn_failure
      # We must raise an error that Bundler recognises otherwise it prints a
      # huge amount of output. `Bundler::GemspecError` just outputs the error
      # message we set in red.
      raise Bundler::GemspecError, 'StrongVersions failure'
    end

    def warn_failure
      @terminal.warn("\n#{I18n.t('strong_versions.errors.failure')}\n")
      @invalid_gems.each do |gem|
        @terminal.output_errors(gem)
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
