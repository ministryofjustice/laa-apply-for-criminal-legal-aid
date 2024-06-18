module Evidence
  module Rules
    class CashInvestments < Rule
      include Evidence::RuleDsl

      key :capital_cash_investments_20
      group :capital

      client do |_crime_application, applicant|
        applicant.savings.other.any? || applicant.joint_savings.other.any?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          (partner.savings.other.any? || partner.joint_savings.other.any?)
      end
    end
  end
end
