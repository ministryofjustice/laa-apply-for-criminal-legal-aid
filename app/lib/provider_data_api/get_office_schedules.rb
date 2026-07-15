module ProviderDataApi
  class GetOfficeSchedules
    def initialize(office_code:, area_of_law:, http_client: HttpClient.call)
      @office_code = office_code
      @area_of_law = Types::AreaOfLaw[area_of_law] if area_of_law
      @http_client = http_client
    end

    # If found returns a ProviderDataApi::OfficeSchedules struct
    # otherwise raises ProviderDataApi::RecordNotFound
    def call
      response = http_client.get(schedules_endpoint(office_code))
      office_schedules(response)
    rescue Faraday::ResourceNotFound
      report_not_found
      raise RecordNotFound
    rescue Faraday::Error => e
      report_failure(e)
      raise
    end

    class << self
      def call(office_code, area_of_law: nil)
        new(office_code:, area_of_law:).call
      end
    end

    private

    attr_reader :office_code, :http_client, :area_of_law

    def operation
      RequestMonitor::OPERATION_GET_OFFICE_SCHEDULES
    end

    def schedules_endpoint(office_code)
      path = "/provider-offices/#{office_code}/schedules"

      URI::Generic.build(path:, query:)
    end

    def query
      return unless area_of_law

      URI.encode_www_form(
        'areaOfLaw' => area_of_law
      )
    end

    def office_schedules(response)
      return success_response(response) if response.status == 200

      report_not_found(status: response.status)
      raise RecordNotFound
    end

    def success_response(response)
      RequestMonitor.record_success(operation: operation, status: response.status)
      OfficeSchedules.new(response.body)
    end

    def report_not_found(status: nil)
      RequestMonitor.record_not_found(operation:, status:)
    end

    def report_failure(error)
      RequestMonitor.record_failure(operation: operation, exception: error)
      Rails.error.report(error, handled: true, severity: :error, context: failure_context)
    end

    def failure_context
      {
        source: 'provider_data_api',
        operation: operation,
        office_code: office_code,
        area_of_law: area_of_law,
        endpoint: schedules_endpoint(office_code).to_s,
      }
    end
  end
end
