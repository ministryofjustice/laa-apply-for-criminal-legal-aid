module Evidence
  module Rules
    class BuildingSocietyAccounts < Rule
      include Evidence::RuleDsl

      key :capital_building_society_accounts_17
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.savings.building_society.any? || applicant.joint_savings.building_society.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) && (
            partner.savings.building_society.any? ||
              partner.joint_savings.building_society.any?
          )
      end
    end
  end
end
