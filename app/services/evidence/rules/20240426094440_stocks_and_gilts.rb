module Evidence
  module Rules
    class StocksAndGilts < Rule
      include Evidence::RuleDsl

      key :capital_stocks_gilts_23
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::STOCK.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::STOCK.value).any?
      end
    end
  end
end
