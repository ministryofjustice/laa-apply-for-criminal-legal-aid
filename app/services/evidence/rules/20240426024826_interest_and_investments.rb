module Evidence
  module Rules
    class InterestAndInvestments < Rule
      include Evidence::RuleDsl

      key :income_investments_7
      group :income

      client do |_crime_application, applicant|
        applicant.income_payments.interest_investment.present?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          partner.income_payments.interest_investment.present?
      end
    end
  end
end
