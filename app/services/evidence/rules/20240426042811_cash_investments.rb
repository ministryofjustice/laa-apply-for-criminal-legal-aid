module Evidence
  module Rules
    class CashInvestments < Rule
      include Evidence::RuleDsl

      key :capital_cash_investments_20
      group :capital

      client do |crime_application|
        crime_application.capital&.client_other_savings.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_other_savings.present?
      end
    end
  end
end
