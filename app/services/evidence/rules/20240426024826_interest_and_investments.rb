module Evidence
  module Rules
    class InterestAndInvestments < Rule
      include Evidence::RuleDsl

      key :income_investments_7
      group :income

      client do |crime_application|
        crime_application.income_payments.interest_investment.present?
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
