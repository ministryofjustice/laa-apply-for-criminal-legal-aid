module Evidence
  module Rules
    class CashIsa < Rule
      include Evidence::RuleDsl

      key :capital_cash_isa_18
      group :capital

      client do |crime_application|
        crime_application.capital&.client_cash_isa_savings.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_cash_isa_savings.present?
      end
    end
  end
end
