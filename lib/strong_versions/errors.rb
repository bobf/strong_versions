module StrongVersions
  module Errors
    class InvalidVersionError < StandardError
      def initialize(invalid_gems, message = nil)
        @invalid_gems = invalid_gems
        super(message)
      end

      def inspect
        "InvalidVersionError: #{@invalid_gems.map(:errors)}"
      end
    end
  end
end
