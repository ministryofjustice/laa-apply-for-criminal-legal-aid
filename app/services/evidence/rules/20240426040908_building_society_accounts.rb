module Evidence
  module Rules
    class BuildingSocietyAccounts < Rule
      include Evidence::RuleDsl

      key :capital_building_society_accounts_17
      group :capital

      client do |_crime_application, applicant|
        applicant.savings(SavingType::BUILDING_SOCIETY).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.savings(SavingType::BUILDING_SOCIETY).any?
      end
    end
  end
end
