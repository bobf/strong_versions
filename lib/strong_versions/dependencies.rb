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
      auto_correct = options.delete(:auto_correct) { false }
      if validate(options)
        summary
        return true
      end

      return update_definitions if auto_correct

      raise_or_warn(options.fetch(:on_failure, 'raise'))
      summary
      false
    end

    def validate(options = {})
      unsafe_autocorrect_error if options[:auto_correct]
      @dependencies.each do |dependency|
        next if options.fetch(:except, []).include?(dependency.name)
        next if dependency.valid?

        @invalid_gems.push(dependency) unless dependency.valid?
      end
      @invalid_gems.empty?
    end

    private

    def unsafe_autocorrect_error
      raise UnsafeAutoCorrectError, 'Must use #validate! for autocorrect'
    end

    def summary
      @terminal.summary(@dependencies.size, @invalid_gems.size)
    end

    def updatable_dependencies
      @dependencies.select(&:updatable?)
    end

    def update_definitions
      @terminal.update_summary(update(:gemfile) + update(:gemspec))
    end

    def update(subject)
      updatable_dependencies.reduce(0) do |count, dependency|
        next count unless dependency.updatable?

        update_dependency(subject, dependency) ? count : count + 1
      end
    end

    def update_dependency(subject, dependency)
      path = dependency.public_send(subject)
      return if path.nil?

      content = File.read(path)
      update = replace_gem_definition(subject, dependency, content)
      return false if content == update

      File.write(path, update)
      @terminal.gem_update(path, dependency, subject)
      true
    end

    def replace_gem_definition(subject, dependency, content)
      regex = gem_regex(subject, dependency.name)
      match = content.match(regex)
      return content unless match

      indent = match.captures.first
      definition = dependency.suggested_definition(subject)
      content.gsub(regex, "#{indent}#{definition}")
    end

    def gem_regex(subject, name)
      {
        gemfile: /^(\s*)gem\s+['"]#{name}['"].*$/,
        gemspec: /^(\s*)spec.add_[a-z_]*_dependency\s+['"]#{name}['"].*$/
      }.fetch(subject)
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
