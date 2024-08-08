module Evidence
  module Rules
    class StocksAndGilts < Rule
      include Evidence::RuleDsl

      key :capital_stocks_gilts_23
      group :capital

      client do |crime_application|
        crime_application.capital&.client_stock_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_stock_investments.present?
      end
    end
  end
end
