module ProviderDataApi
  class GetOfficeSchedules
    def initialize(office_code:, area_of_law:, http_client: HttpClient.call)
      @office_code = office_code
      @area_of_law = Types::AreaOfLaw[area_of_law] if area_of_law
      @http_client = http_client
    end

    # Returns a ProviderDataApi::OfficeSchedules struct
    def call
      response = http_client.get(schedules_endpoint(office_code))
      raise ProviderDataApi::RecordNotFound unless response.status == 200

      ProviderDataApi::OfficeSchedules.new(response.body)
    end

    class << self
      def call(office_code, area_of_law: nil)
        new(office_code:, area_of_law:).call
      end
    end

    private

    attr_reader :office_code, :http_client, :area_of_law

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
  end
end
