module Evidence
  module Rules
    class PepPlans < Rule
      include Evidence::RuleDsl

      key :capital_pep_25
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::PEP.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::PEP.value).any?
      end
    end
  end
end
