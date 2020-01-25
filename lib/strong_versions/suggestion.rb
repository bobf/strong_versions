# frozen_string_literal: true

module StrongVersions
  class Suggestion
    def initialize(version)
      return if version.nil?

      @parts = version.split('.')
      # Treat '4.3.2.1' as '4.3.2'
      @parts.pop if standard?(@parts.first(3)) && @parts.size == 4
    end

    def to_s
      return version.to_s if version.nil?

      "'~> #{version}'"
    end

    def version
      return nil unless standard?

      major, minor, patch = @parts
      return "#{major}.#{minor}" if stable?
      return "#{major}.#{minor}.#{patch}" if unstable?

      raise 'Unexpected condition met'
    end

    def missing?
      return false if stable?
      return false if unstable?

      true
    end

    private

    def unstable?
      standard? && @parts.first.to_i.zero?
    end

    def stable?
      standard? && @parts.first.to_i >= 1
    end

    def standard?(parts = @parts)
      return false if parts.nil?
      return false unless numeric?
      return true if [2, 3].include?(parts.size)
      return true if parts.size == 3 && unstable?

      false
    end

    def numeric?
      @parts.all? { |part| part =~ /\A[0-9]+\Z/ }
    end
  end
end
