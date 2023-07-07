module OrdnanceSurvey
  class AddressLookup
    class UnsuccessfulLookupError < StandardError; end

    ORDNANCE_SURVEY_URL = 'https://api.os.uk/search/places/v1/postcode'.freeze

    attr_reader :postcode,
                :last_exception

    def initialize(postcode)
      @postcode = postcode
    end

    def call
      AddressLookupResults.call(results)
    end

    def success?
      last_exception.nil?
    end

    private

    def query_params
      {
        key: ENV.fetch('ORDNANCE_SURVEY_API_KEY'),
        postcode: postcode,
        lr: 'EN',
      }
    end

    def results
      @results ||= perform_lookup
    end

    def perform_lookup
      uri = URI.parse(ORDNANCE_SURVEY_URL)
      uri.query = query_params.to_query
      response = Faraday.get(uri)

      raise UnsuccessfulLookupError, response.body unless response.success?

      parse_successful_response(
        response.body
      )
    rescue StandardError => e
      Rails.error.report(e, handled: true)
      @last_exception = e
      []
    end

    # Using `fetch` so it raises KeyError exception on purpose
    def parse_successful_response(response)
      parsed_body = JSON.parse(response)

      if parsed_body.fetch('header').fetch('totalresults').positive?
        parsed_body.fetch('results')
      else
        []
      end
    end
  end
end
