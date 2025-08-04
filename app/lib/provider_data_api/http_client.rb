module ProviderDataApi
  class HttpClient
    def initialize(host: Rails.configuration.x.provider_data_api.url)
      @host = host
    end

    def call
      Faraday.new(host) do |f|
        f.headers = { 'X-Authorization': Rails.configuration.x.provider_data_api.secret }
        f.response :raise_error
        f.request :retry, retry_options
        f.request :json
        f.response :json
      end
    end

    class << self
      delegate :call, to: :new
    end

    private

    attr_reader :host

    def retry_options
      {
        methods: [:get, :head],
        retry_statuses: [409],
        interval: 0.05
      }
    end
  end
end
