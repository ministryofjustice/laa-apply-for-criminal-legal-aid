module ProviderDataApi
  module RequestMonitor
    OPERATION_GET_OFFICE_SCHEDULES = 'get_office_schedules'.freeze

    class << self
      def record_success(operation:, status:)
        increment(
          outcome: 'success',
          operation: operation,
          http_status: status,
          error_class: 'none'
        )
      end

      def record_not_found(operation:, status: nil)
        increment(
          outcome: 'not_found',
          operation: operation,
          http_status: status || 404,
          error_class: 'none'
        )
      end

      def record_failure(operation:, exception:, status: nil)
        increment(
          outcome: 'failure',
          operation: operation,
          http_status: status || extract_status(exception) || 'none',
          error_class: exception.class.name
        )
      end

      def snapshot
        mutex.synchronize { counters.dup }
      end

      def activity_snapshot
        mutex.synchronize { activity.dup }
      end

      def reset!
        mutex.synchronize do
          @counters = Hash.new(0)
          @activity = {}
        end
      end

      private

      def increment(outcome:, operation:, http_status:, error_class:)
        labels = {
          outcome: outcome.to_s,
          operation: operation.to_s,
          http_status: http_status.to_s,
          error_class: error_class.to_s,
        }.freeze

        mutex.synchronize do
          counters[labels] += 1
          activity[{ outcome: outcome.to_s, operation: operation.to_s }.freeze] = Time.now.to_f
        end
      end

      def extract_status(exception)
        return unless exception.respond_to?(:response)

        response = exception.response
        return response[:status] if response.is_a?(Hash)

        response.status if response.respond_to?(:status)
      end

      def counters
        @counters ||= Hash.new(0)
      end

      def activity
        @activity ||= {}
      end

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
