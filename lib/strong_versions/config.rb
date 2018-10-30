# frozen_string_literal: true

module StrongVersions
  class Config
    def initialize(path)
      if File.exist?(path)
        @config = YAML.load_file(path)
      else
        @config = nil
      end
    end

    def exceptions
      return [] if @config.nil?

      @config['ignore']
    end

    def on_failure
      return 'raise' if @config.nil?

      @config.fetch('on_failure', 'raise')
    end
  end
end
