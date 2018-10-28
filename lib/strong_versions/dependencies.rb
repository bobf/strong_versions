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

      raise StrongVersions::Errors::InvalidVersionError.new(@invalid_gems)
    end

    def validate
      @dependencies.each do |dependency|
        @invalid_gems.push(dependency) unless dependency.valid?
      end
      @invalid_gems.empty?
    end
  end
end
