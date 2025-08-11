module ProviderDataApi
  class ActiveOfficeCodesFilter
    def initialize(office_codes: [], area_of_law: nil, http_client: HttpClient.call)
      @office_codes = office_codes
      @area_of_law = Types::AreaOfLaw[area_of_law] if area_of_law
      @http_client = http_client
    end

    def call
      office_codes.filter do |office_code|
        response = http_client.head(schedules_endpoint(office_code))

        response.status == 200
      rescue Faraday::ResourceNotFound
        next
      end
    end

    class << self
      def call(office_codes, area_of_law: nil)
        new(office_codes:, area_of_law:).call
      end
    end

    private

    attr_reader :office_codes, :http_client, :area_of_law

    def schedules_endpoint(office_code)
      path = "/provider-offices/#{office_code}/schedules"

      URI::Generic.build(path:, query:)
    end

    def query
      return unless area_of_law

      URI.encode_www_form('areaOfLaw' => area_of_law)
    end
  end
end
