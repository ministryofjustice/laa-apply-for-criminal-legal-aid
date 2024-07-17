module Evidence
  module Rules
    class InvestmentBonds < Rule
      include Evidence::RuleDsl

      key :capital_investment_bonds_28
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::BOND).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::BOND).any?
      end
    end
  end
end
