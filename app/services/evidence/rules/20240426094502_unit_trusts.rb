module Evidence
  module Rules
    class UnitTrusts < Rule
      include Evidence::RuleDsl

      key :capital_unit_trusts_27
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.unit_trust.any? || applicant.investments.unit_trust.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) &&
          (partner.joint_investments.unit_trust.any? || partner.investments.unit_trust.any?)
      end
    end
  end
end
