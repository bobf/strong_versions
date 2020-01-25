# frozen_string_literal: true

module StrongVersions
  class DependencyFinder
    def dependencies
      development + runtime
    end

    private

    def development
      # Gem runtime dependencies are not included here:
      Bundler.definition.resolve
      Bundler.definition.dependencies
    end

    def runtime
      gemspecs.compact.map(&:dependencies).flatten.select do |spec|
        spec.type == :runtime
      end
    end

    def gemspecs
      gemspec_paths.map { |path| Bundler.load_gemspec(path) }
    end

    def gemspec_paths
      Dir[File.join(Bundler.default_gemfile.dirname, '{,*}.gemspec')]
    end
  end
end
