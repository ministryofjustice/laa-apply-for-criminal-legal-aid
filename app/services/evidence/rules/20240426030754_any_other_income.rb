module Evidence
  module Rules
    class AnyOtherIncome < Rule
      include Evidence::RuleDsl

      key :income_other_9
      group :income

      client do |crime_application|
        other_income = crime_application.income_payments.other

        other_income.present? && other_income.details.present?
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        # Predicate must return true or false
        false
      end
    end
  end
end
