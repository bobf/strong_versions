# frozen_string_literal: true

module StrongVersions
  class Exceptions
    def self.find_all(path)
      return [] unless File.exist?(path)

      YAML.load_file(path).fetch('exceptions', [])
    end
  end
end
