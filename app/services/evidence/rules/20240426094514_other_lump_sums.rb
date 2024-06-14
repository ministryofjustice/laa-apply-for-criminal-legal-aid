module Evidence
  module Rules
    class OtherLumpSums < Rule
      include Evidence::RuleDsl

      key :capital_other_lump_sums_29
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.other.any? || applicant.investments.other.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.other.any? || partner.investments.other.any?
      end
    end
  end
end
