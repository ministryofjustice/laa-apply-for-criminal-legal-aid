module Evidence
  module Rules
    class StocksAndGilts < Rule
      include Evidence::RuleDsl

      key :capital_stocks_gilts_23
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::STOCK).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::STOCK).any?
      end
    end
  end
end
