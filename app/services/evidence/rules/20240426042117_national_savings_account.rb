module Evidence
  module Rules
    class NationalSavingsAccount < Rule
      include Evidence::RuleDsl

      key :capital_nsa_19
      group :capital

      client do |_crime_application, applicant|
        applicant.savings.national_savings_or_post_office.any? ||
          applicant.joint_savings.national_savings_or_post_office.any?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) && (
          partner.savings.national_savings_or_post_office.any? ||
            partner.joint_savings.national_savings_or_post_office.any?
        )
      end
    end
  end
end
