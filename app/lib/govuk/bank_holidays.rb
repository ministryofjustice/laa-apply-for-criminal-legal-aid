module Govuk
  class BankHolidays
    DEFAULT_REGION = 'england-and-wales'.freeze

    def self.call(region = DEFAULT_REGION)
      new.call(region)
    end

    def call(region = DEFAULT_REGION)
      return if data.blank?

      dates = data.dig(region, 'events')&.pluck('date')
      return if dates.nil?

      dates.map { |date| Date.parse(date) }
    end

    private

    def data
      @data ||= Rails.cache.fetch('bank-holidays', expires_in: 3.months) do
        res = connection.get
        JSON.parse(res.body)
      end
    end

    def connection
      @connection ||= Faraday.new(Rails.configuration.x.bank_holidays_api.url) do |builder|
        builder.response :raise_error
      end
    end
  end
end
