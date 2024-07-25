module Evidence
  module Rules
    class BuildingSocietyAccounts < Rule
      include Evidence::RuleDsl

      key :capital_building_society_accounts_17
      group :capital

      client do |crime_application|
        crime_application.capital&.client_building_society_savings.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_building_society_savings.present?
      end
    end
  end
end
