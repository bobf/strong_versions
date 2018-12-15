# frozen_string_literal: true

module StrongVersions
  class Terminal
    COLOR_CODES = {
      red: 31,
      green: 32,
      light_red: 91
    }.freeze

    def initialize(file = STDERR)
      @file = file
      check_i18n
    end

    def warn(string)
      puts(color(:light_red, string))
    end

    def success(prefix, highlight, suffix)
      puts
      puts(prefix + color(:green, highlight) + suffix)
    end

    def output_errors(gem)
      definition = color(:light_red, gem.definition)
      puts('`' + color(:red, gem.name) + '`: ' + definition)
      puts(format_errors(gem.errors))
      suggested = '  ' + I18n.t('strong_versions.errors.suggested')
      puts(suggested + color(:green, gem.suggestion)) unless gem.suggestion.missing?
      puts
    end

    def puts(string = '')
      @file.puts(string)
    end

    private

    def format_errors(errors)
      errors.map do |error|
        type = I18n.t("strong_versions.errors.#{error[:type]}")
        value = color(:light_red, error[:value])
        "  #{type} #{example(error[:type])}, found: #{value}"
      end
    end

    def example(type)
      case type
      when :operator
        color(:green, '~>')
      when :version
        "'#{color(:green, '1.2')}' or '#{color(:green, '0.2.3')}'"
      else
        raise ArgumentError
      end
    end

    def color(name, string)
      code = COLOR_CODES.fetch(name)
      "\033[#{code}m#{string}\033[39m"
    end

    def check_i18n
      return unless I18n.respond_to?(:_strong_versions__stub)

      warn("\nStrongVersions: `i18n` not installed. Using fallback.")
    end
  end
end
