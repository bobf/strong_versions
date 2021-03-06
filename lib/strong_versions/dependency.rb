# frozen_string_literal: true

module StrongVersions
  # rubocop:disable Metrics/ClassLength
  class Dependency
    attr_reader :name, :errors

    def initialize(dependency, lockfile = nil)
      @dependency = dependency
      @name = dependency.name
      @errors = []
      @lockfile = lockfile || default_lockfile

      versions.each { |operator, version| validate_version(operator, version) }
    end

    def to_s
      "#<StrongVersions::Dependency name=#{@dependency.name}>"
    end

    def gemfile
      Pathname.new(@dependency.gemfile) if @dependency.respond_to?(:gemfile)
    end

    def gemspec
      Pathname.new(gemspec_path) unless gemspec_path.nil?
    end

    def valid?
      @errors.empty?
    end

    def suggested_version
      GemVersion.new(GemVersion.new(lockfile_version).version_string)
    end

    def suggested_definition(subject = :gemfile)
      guards = guard_versions.map { |op, version| "'#{op} #{version}'" }
      constraints = [suggested_version.suggestion, *guards].join(', ')
      send(:"suggested_#{subject}_definition", constraints)
    end

    def definition
      versions.map do |operator, version|
        next t('version_not_specified') if operator == '>=' && version.zero?

        "'#{operator} #{version}'"
      end.join(', ')
    end

    def updatable?
      !valid? && !suggested_version.missing? && !path_source?
    end

    private

    def gemspec_path
      _spec, path = gemspec_dependency
      path
    end

    def gemspec_spec
      spec, _path = gemspec_dependency
      spec
    end

    def gemspec_dependency
      DependencyFinder.new.gemspec_dependencies.each do |path, specs|
        specs.each do |spec|
          return [spec, path] if spec.name == @dependency.name
        end
      end
      nil
    end

    def suggested_gemspec_definition(constraints)
      "add_#{gemspec_spec.type}_dependency '#{@name}', #{constraints}"
    end

    def suggested_gemfile_definition(constraints)
      "gem '#{@name}', #{constraints}"
    end

    def versions
      @dependency.requirements_list.map { |version| parse_version(version) }
    end

    def guard_versions
      versions.reject { |op, version| redundant?(op, version) }
    end

    def parse_version(requirement)
      operator, version_obj = Gem::Requirement.parse(requirement)
      [operator, GemVersion.new(version_obj)]
    end

    def lockfile_version
      @lockfile_version ||= begin
        gem_spec = @lockfile.specs.find { |spec| spec.name == @name }
        gem_spec.nil? ? nil : gem_spec.version
      end
    end

    def default_lockfile
      Bundler::LockfileParser.new(Bundler.read_file(Bundler.default_lockfile))
    end

    def validate_version(operator, version)
      return if path_source?
      return if any_valid?

      check_pessimistic(operator) unless version.zero?
      check_valid_version(version)
    end

    def check_pessimistic(operator)
      return if pessimistic?(operator)

      @errors << { type: :operator, value: operator }
    end

    def check_valid_version(version)
      return if version.valid?

      value = version.zero? ? t('version_not_specified') : version
      @errors << { type: :version, value: value }
    end

    def redundant?(operator, version)
      return true if pessimistic?(operator)
      return false if guard_needed?(operator, version)

      true
    end

    def guard_needed?(operator, version)
      return false unless %w[< <= > >=].include?(operator)
      return true if %(< <=).include?(operator) && suggested_version < version
      return true if %(> >=).include?(operator) && suggested_version < version

      false
    end

    def pessimistic?(operator)
      operator == '~>'
    end

    def any_valid?
      versions.any? do |operator, version|
        pessimistic?(operator) && version.valid?
      end
    end

    def path_source?
      # Bundler::Source::Git inherits from Bundler::Source::Path so git sources
      # will also return `true`.
      @dependency.source.is_a?(Bundler::Source::Path)
    end

    def t(name)
      I18n.t("strong_versions.#{name}")
    end
  end
  # rubocop:enable Metrics/ClassLength
end
