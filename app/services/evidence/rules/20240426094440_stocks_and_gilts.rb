module Evidence
  module Rules
    class StocksAndGilts < Rule
      include Evidence::RuleDsl

      key :capital_stocks_gilts_23
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.stock.any? || applicant.investments.stock.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.stock.any? || partner.investments.stock.any?
      end
    end
  end
end
