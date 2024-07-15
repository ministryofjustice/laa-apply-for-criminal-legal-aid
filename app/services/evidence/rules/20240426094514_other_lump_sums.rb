module Evidence
  module Rules
    class OtherLumpSums < Rule
      include Evidence::RuleDsl

      key :capital_other_lump_sums_29
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.other.any? || applicant.investments.other.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) &&
          (partner.joint_investments.other.any? || partner.investments.other.any?)
      end
    end
  end
end
