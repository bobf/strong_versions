module StrongVersions
  class Dependencies
    def initialize(dependencies)
      @dependencies = dependencies.map do |raw_dependency|
        Dependency.new(raw_dependency)
      end
      @invalid_gems = []
    end

    def validate!
      return if validate

      raise Bundler::GemspecError,
            "StrongVersions expectations not met: #{error_message}"
    end

    def validate
      @dependencies.each do |dependency|
        @invalid_gems.push(dependency) unless dependency.valid?
      end
      @invalid_gems.empty?
    end

    def error_message
      @invalid_gems.map do |invalid_gem|
        "#{invalid_gem.name}: #{invalid_gem.errors}"
      end.join(', ')
    end
  end
end
