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

      on_failure = options.fetch(:on_failure, 'raise')
      case on_failure
      when 'raise'
        raise_failure
      when 'warn'
        warn_failure
      end
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

    def raise_failure
      warn_failure
      # We must raise an error that Bundler recognises otherwise it prints a
      # huge amount of output. `Bundler::GemspecError` just outputs the error
      # message we set in red.
      raise Bundler::GemspecError, 'StrongVersions failure'
    end

    def warn_failure
      STDERR.puts("\n" + 'StrongVersions expectations not met:'.red + "\n\n")
      @invalid_gems.each do |gem|
        STDERR.puts(format_errors(gem.name, gem.errors))
      end
      STDERR.puts("\n")
    end

    def raise_unknown(on_failure)
      raise Bundler::Error,
            I18n.t('errors.unknown_on_failure', on_failure: on_failure)
    end

    def format_errors(name, errors)
      message = "#{name}: ".green
      message + errors.map do |error|
        type = I18n.t("errors.#{error[:type]}").red
        value = error[:value].light_red
        '"'.red + "#{type} #{value}" + '"'.red
      end.join(', '.red)
    end
  end
end
