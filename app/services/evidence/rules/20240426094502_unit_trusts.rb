module Evidence
  module Rules
    class UnitTrusts < Rule
      include Evidence::RuleDsl

      key :capital_unit_trusts_27
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.unit_trust.any? || applicant.investments.unit_trust.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.unit_trust.any? || partner.investments.unit_trust.any?
      end
    end
  end
end
