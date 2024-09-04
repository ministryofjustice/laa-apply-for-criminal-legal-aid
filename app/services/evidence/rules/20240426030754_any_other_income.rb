module Evidence
  module Rules
    class AnyOtherIncome < Rule
      include Evidence::RuleDsl

      key :income_other_9
      group :income

      client do |crime_application|
        crime_application.income&.client_other_payment.present?
      end

      partner do |crime_application|
        crime_application.income&.partner_other_payment.present?
      end
    end
  end
end
