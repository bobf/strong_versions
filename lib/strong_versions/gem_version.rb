# frozen_string_literal: true

module StrongVersions
  class GemVersion
    def initialize(version)
      @version = normalize(version) || ''
      @parts = @version&.split('.')
    end

    def to_s
      @version
    end

    def zero?
      @version == '0'
    end

    def suggestion
      return '' if version_string.empty?

      "'~> #{version_string}'"
    end

    def version_string
      return '' unless standard?

      major, minor, patch = @parts
      return "#{major}.#{minor}" if stable?
      return "#{major}.#{minor}.#{patch}" if unstable?

      raise 'Unexpected condition met'
    end

    def <(other)
      numeric < other.numeric
    end

    def <=(other)
      numeric <= other.numeric
    end

    def >(other)
      numeric > other.numeric
    end

    def >=(other)
      numeric >= other.numeric
    end

    def numeric
      # Support extremely precise versions e.g. '1.2.3.4.5.6.7.8.9'
      components = @version.split('.').map(&:to_i)
      components += [0] * (10 - components.size)
      components.reverse.each_with_index.map do |component, index|
        component * 10.pow(index + 1)
      end.sum
    end

    def valid?
      return true if @version =~ /^[1-9][0-9]*\.\d+$/ # major.minor, e.g. "2.5"
      return true if @version =~ /^0\.\d+\.\d+$/ # 0.minor.patch, e.g. "0.1.8"

      false
    end

    def missing?
      return false if stable?
      return false if unstable?

      true
    end

    private

    def normalize(version)
      # Ruby >= 2.3.0: `version_obj` is a `Gem::Version`
      return version.version.to_s if version.respond_to?(:version)

      # Ruby < 2.3.0: `version_obj` is a `String`
      version
    end

    def unstable?
      standard? && @parts.first.to_i.zero?
    end

    def stable?
      standard? && @parts.first.to_i >= 1
    end

    def standard?(parts = @parts)
      return false if parts.nil?
      return false unless numeric?
      return true if [2, 3, 4].include?(parts.size)
      return true if parts.size == 3

      false
    end

    def numeric?
      @parts.all? { |part| part =~ /\A[0-9]+\Z/ }
    end
  end
end
