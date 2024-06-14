module Evidence
  module Rules
    class AnyOtherIncome < Rule
      include Evidence::RuleDsl

      key :income_other_9
      group :income

      client do |_crime_application, applicant|
        other_income = applicant.income_payments.other

        other_income.present? && other_income.details.present?
      end

      partner do |_crime_application, partner|
        other_income = partner.income_payments.other

        other_income.present? && other_income.details.present?
      end
    end
  end
end
