# frozen_string_literal: true

module StrongVersions
  class Suggestion
    def initialize(version)
      @parts = version.split('.') unless version.nil?
    end

    def to_s
      return version.to_s if version.nil?

      "'~> #{version}'"
    end

    def missing?
      return false if stable?
      return false if unstable?

      true
    end

    private

    def version
      major, minor, patch = @parts if standard?

      return "#{major}.#{minor}" if stable?
      return "#{major}.#{minor}.#{patch}" if unstable?

      nil
    end

    def unstable?
      standard? && @parts.first.to_i.zero?
    end

    def stable?
      standard? && @parts.first.to_i >= 1
    end

    def standard?
      return false if @parts.nil?
      return false unless @parts.size == 3
      return false unless numeric?

      true
    end

    def numeric?
      @parts.all? { |part| part =~ /\A[0-9]+\Z/ }
    end
  end
end
