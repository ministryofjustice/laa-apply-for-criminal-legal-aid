module Evidence
  module Rules
    class PepPlans < Rule
      include Evidence::RuleDsl

      key :capital_pep_25
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::PEP).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::PEP).any?
      end
    end
  end
end
