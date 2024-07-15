module Evidence
  module Rules
    class PepPlans < Rule
      include Evidence::RuleDsl

      key :capital_pep_25
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.pep.any? || applicant.investments.pep.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) &&
          (partner.joint_investments.pep.any? || partner.investments.pep.any?)
      end
    end
  end
end
