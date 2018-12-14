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
      puts(color(:red, string))
    end

    def success(string)
      puts(color(:green, string))
    end

    def output_errors(name, errors)
      puts(format_errors(name, errors))
    end

    def puts(string)
      @file.puts(string)
    end

    private

    def format_errors(name, errors)
      message = color(:green, "#{name}: ")
      message + errors.map do |error|
        type = color(:red, I18n.t("strong_versions.errors.#{error[:type]}"))
        value = color(:light_red, error[:value])
        color(:red, '"') + "#{type} #{value}" + color(:red, '"')
      end.join(color(:red, ', '))
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
