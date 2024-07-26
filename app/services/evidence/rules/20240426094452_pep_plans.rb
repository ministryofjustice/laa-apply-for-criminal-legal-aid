module Evidence
  module Rules
    class PepPlans < Rule
      include Evidence::RuleDsl

      key :capital_pep_25
      group :capital

      client do |crime_application|
        crime_application.capital&.client_pep_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_pep_investments.present?
      end
    end
  end
end
