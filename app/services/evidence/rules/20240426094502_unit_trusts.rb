module Evidence
  module Rules
    class UnitTrusts < Rule
      include Evidence::RuleDsl

      key :capital_unit_trusts_27
      group :capital

      client do |crime_application|
        crime_application.capital&.client_unit_trust_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_unit_trust_investments.present?
      end
    end
  end
end
