module Evidence
  module Rules
    class BuildingSocietyAccounts < Rule
      include Evidence::RuleDsl

      key :capital_building_society_accounts_17
      group :capital

      client do |crime_application|
        crime_application.savings.for_client.where(saving_type: SavingType::BUILDING_SOCIETY.value).any?
      end

      partner do |crime_application|
        crime_application.savings.for_partner.where(saving_type: SavingType::BUILDING_SOCIETY.value).any?
      end
    end
  end
end
