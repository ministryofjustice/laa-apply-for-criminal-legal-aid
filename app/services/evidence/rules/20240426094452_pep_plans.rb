module Evidence
  module Rules
    class PepPlans < Rule
      include Evidence::RuleDsl

      key :capital_pep_25
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.pep.any? || applicant.investments.pep.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.pep.any? || partner.investments.pep.any?
      end
    end
  end
end
