module Evidence
  module Rules
    class InvestmentBonds < Rule
      include Evidence::RuleDsl

      key :capital_investment_bonds_28
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::BOND.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::BOND.value).any?
      end
    end
  end
end
