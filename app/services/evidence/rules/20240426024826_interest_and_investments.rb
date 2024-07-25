module Evidence
  module Rules
    class InterestAndInvestments < Rule
      include Evidence::RuleDsl

      key :income_investments_7
      group :income

      client do |crime_application, _applicant|
        crime_application.income&.client_interest_investment_payment.present?
      end

      partner do |crime_application, _partner|
        crime_application.income&.partner_interest_investment_payment.present?
      end
    end
  end
end
