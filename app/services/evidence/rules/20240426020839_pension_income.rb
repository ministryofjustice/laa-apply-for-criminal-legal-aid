module Evidence
  module Rules
    class PrivatePensionIncome < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      # Note this is per month
      THRESHOLD = 1000.00

      key :income_private_pension_5
      group :income

      client do |crime_application, _applicant|
        payment = crime_application.income&.client_private_pension_payment

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end

      partner do |crime_application, _partner|
        payment = crime_application.income&.partner_private_pension_payment

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end
    end
  end
end
