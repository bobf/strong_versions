module StrongVersions
  class Dependency
    attr_reader :errors

    def initialize(dependency)
      @dependency = dependency
      @errors = []

      versions.each do |operator, version|
        validate_version(operator, version)
      end
    end

    def valid?
      @errors.empty?
    end

    private

    def versions
      @dependency.requirements_list.map do |requirement|
        parse_version(requirement)
      end
    end

    def parse_version(requirement)
      operator, version_obj = Gem::Requirement.parse(requirement)
      if version_obj.respond_to?(:version)
        # Ruby >= 2.3.0: `version_obj` is a `Gem::Version`
        [operator, version_obj.version]
      else
        # Ruby < 2.3.0: `version_obj` is a `String`
        [operator, version_obj]
      end
    end

    def validate_version(operator, version)
      # TODO: Handle user-specified overrides
      if operator != '~>'
        @errors << I18n.t('errors.pessimistic', operator: operator)
      end

      if !valid_version?(version)
        @errors << I18n.t('errors.version', version: version)
      end
    end

    def valid_version?(version)
      return true if version.match(/^\d+\.\d+$/) # major.minor, e.g. "2.5"

      false
    end
  end
end
