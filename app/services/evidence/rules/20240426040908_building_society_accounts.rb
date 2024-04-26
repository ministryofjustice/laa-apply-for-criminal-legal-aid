module Evidence
  module Rules
    class BuildingSocietyAccounts < Rule
      include Evidence::RuleDsl

      key :capital_building_society_accounts_17
      group :capital

      client do |crime_application|
        if crime_application.savings
          crime_application.savings.where(saving_type: SavingType::BUILDING_SOCIETY.value).size.positive?
        else
          false
        end
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
