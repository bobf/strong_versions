# frozen_string_literal: true

module StrongVersions
  class Dependency
    attr_reader :name, :errors

    def initialize(dependency, lockfile = nil)
      @dependency = dependency
      @name = dependency.name
      @errors = []
      @lockfile = lockfile || default_lockfile

      versions.each do |operator, version|
        validate_version(operator, version)
      end
    end

    def gemfile
      Pathname.new(@dependency.gemfile) if @dependency.respond_to?(:gemfile)
    end

    def valid?
      @errors.empty?
    end

    def suggestion
      Suggestion.new(lockfile_version)
    end

    def suggested_definition
      guards = guard_versions.map { |op, version| "'#{op} #{version}'" }
      combined = [suggestion, *guards].join(', ')
      "gem '#{@name}', #{combined}"
    end

    def definition
      versions.map { |operator, version| "'#{operator} #{version}'" }.join(', ')
    end

    def updatable?
      return false unless gemfile
      return false if suggestion.missing?
      return false if path_source?

      true
    end

    private

    def versions
      @dependency.requirements_list.map do |requirement|
        parse_version(requirement)
      end
    end

    def guard_versions
      versions.reject { |op, _version| pessimistic?(op) }
              .reject { |op, version| redundant?(op, version) }
    end

    def parse_version(requirement)
      operator, version_obj = Gem::Requirement.parse(requirement)
      [operator, version(version_obj)]
    end

    def lockfile_version
      @lockfile_version ||= begin
        gem_spec = @lockfile.specs.find { |spec| spec.name == @name }
        gem_spec.nil? ? nil : version(gem_spec.version)
      end
    end

    def default_lockfile
      Bundler::LockfileParser.new(Bundler.read_file(Bundler.default_lockfile))
    end

    def version(version_obj)
      # Ruby >= 2.3.0: `version_obj` is a `Gem::Version`
      return version_obj.version if version_obj.respond_to?(:version)

      # Ruby < 2.3.0: `version_obj` is a `String`
      version_obj
    end

    def validate_version(operator, version)
      return if path_source?
      return if any_valid?

      check_pessimistic(operator)
      check_valid_version(version)
    end

    def check_pessimistic(operator)
      return if pessimistic?(operator)

      @errors << { type: :operator, value: operator }
    end

    def check_valid_version(version)
      return if valid_version?(version)

      value = if version == '0'
                I18n.t('strong_versions.version_not_specified')
              else
                version
              end
      @errors << { type: :version, value: value }
    end

    def redundant?(operator, version)
      return false unless operator.start_with?('>')

      multiply_version(version) <= multiply_version(suggestion.version)
    end

    def multiply_version(version)
      components = version.split('.')
      # Support extremely precise versions e.g. '1.2.3.4.5.6.7.8.9'
      components += ['0'] * (10 - components.size)
      components.reverse.each_with_index.map do |component, index|
        component.to_i * 10.pow(index + 1)
      end.sum
    end

    def pessimistic?(operator)
      operator == '~>'
    end

    def valid_version?(version)
      return true if version =~ /^[1-9][0-9]*\.\d+$/ # major.minor, e.g. "2.5"
      return true if version =~ /^0\.\d+\.\d+$/ # 0.minor.patch, e.g. "0.1.8"

      false
    end

    def any_valid?
      versions.any? do |operator, version|
        pessimistic?(operator) && valid_version?(version)
      end
    end

    def path_source?
      # Bundler::Source::Git inherits from Bundler::Source::Path so git sources
      # will also return `true`.
      @dependency.source.is_a?(Bundler::Source::Path)
    end

    def pessimistic_with_upper_bound?(operator)
      any_pessimistic? && %w[< <=].include?(operator)
    end

    def any_pessimistic?
      p versions
      versions.any? { |operator, _version| pessimistic?(operator) }
    end
  end
end
