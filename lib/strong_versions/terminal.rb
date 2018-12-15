# frozen_string_literal: true

module StrongVersions
  class Terminal
    def initialize(file = STDERR)
      @file = file
    end

    def warn(string)
      puts(color(string, :underline, :bright, :red))
    end

    def summary(count, failed)
      return puts(success(count)) if failed.zero?

      puts(failure(count, failed))
    end

    def output_errors(gem)
      puts(name_and_definition(gem))

      puts(format_errors(gem.errors))
      suggestion(gem)
      puts
    end

    def puts(string = '')
      @file.puts(string)
    end

    private

    def t(name)
      I18n.t("strong_versions.#{name}")
    end

    # Success and failure output format brazenly stolen from Rubocop.
    def success(count)
      color(
        "#{count} #{t('checked')}, %{no_issues} #{t('detected')}",
        :default,
        no_issues: [t('no_issues'), :green]
      )
    end

    def failure(count, failed)
      issues = "#{failed} " + (failed == 1 ? t('issue') : t('issues'))
      color(
        "#{count} #{t('checked')}, %{issues} #{t('detected')}",
        :default,
        issues: [issues, :red]
      )
    end

    def format_errors(errors)
      errors.map do |error|
        type = t("errors.#{error[:type]}")
        color(
          '  %{type} %{example}, found: %{found}',
          :default,
          type: [type, :default],
          example: example(error[:type]),
          found: [error[:value], :red]
        )
      end
    end

    def suggestion(gem)
      suggested = '  ' + t('errors.suggested')
      puts(
        color(
          "#{suggested} %{suggestion}",
          :default,
          suggestion: [gem.suggestion.to_s, :green]
        )
      )
    end

    def name_and_definition(gem)
      color(
        '`%{name}`: %{definition}',
        :default,
        name: [gem.name, :reset, :bright, :red],
        definition: [gem.definition, :reset, :red]
      )
    end

    def example(type)
      case type
      when :operator
        color('~>', :green)
      when :version
        color('%{major} or %{minor}', :default, major: ['1.2', :green],
                                                minor: ['0.2.3', :green])
      else
        raise ArgumentError
      end
    end

    def color(string, *substitutions)
      # rubocop:disable Style/FormatString, Layout/SpaceAroundOperators
      Paint%[string.dup, *substitutions]
      # rubocop:enable Style/FormatString, Layout/SpaceAroundOperators
    end
  end
end
