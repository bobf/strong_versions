# frozen_string_literal: true

module StrongVersions
  class InstallDetector
    def initialize(gemfiles = nil)
      @gemfiles = gemfiles.nil? ? Bundler.definition.gemfiles : gemfiles
      @dsl = GemfileDSL.new
    end

    def installed?
      @gemfiles.each do |gemfile|
        # Bundler uses the same strategy to parse Gemfiles.
        @dsl.instance_eval(
          Bundler.read_file(gemfile).dup.untaint, gemfile.to_s, 1
        )
      end

      @dsl._strong_versions__installed
    end
  end
end
