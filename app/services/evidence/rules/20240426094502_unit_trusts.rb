module Evidence
  module Rules
    class UnitTrusts < Rule
      include Evidence::RuleDsl

      key :capital_unit_trusts_27
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::UNIT_TRUST.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::UNIT_TRUST.value).any?
      end
    end
  end
end
