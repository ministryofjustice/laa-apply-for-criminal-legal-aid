module Evidence
  module Rules
    class MaintenanceIncome < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 500.00

      key :income_maintenance_6
      group :income

      client do |crime_application|
        payment = crime_application.income&.client_maintenance_payment

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end

      partner do |crime_application|
        payment = crime_application.income&.partner_maintenance_payment

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end
    end
  end
end
