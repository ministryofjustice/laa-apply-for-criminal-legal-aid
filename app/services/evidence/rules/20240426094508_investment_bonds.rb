module Evidence
  module Rules
    class InvestmentBonds < Rule
      include Evidence::RuleDsl

      key :capital_investment_bonds_28
      group :capital

      client do |crime_application|
        crime_application.capital&.client_bond_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_bond_investments.present?
      end
    end
  end
end
