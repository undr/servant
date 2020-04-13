module Servant
  module Exceptions
    class Base < StandardError
      attr_reader :errors

      def initialize(errors, message = '')
        super(message.presence || default_message(errors))
        @errors = errors
      end

      private

      def default_message(errors)
        "Got errors: #{errors.full_messages.join(", ")}"
      end
    end

    class ExecutionAborted < Base
    end

    class ExecutionFailed < Base
    end
  end
end
