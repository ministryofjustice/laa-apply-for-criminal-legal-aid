module Evidence
  module Rules
    class ChildMaintenanceCosts < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 500.00

      key :outgoings_maintenance_15
      group :outgoings

      client do |crime_application|
        payment = crime_application.outgoings&.maintenance

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end

      partner do |crime_application|
        payment = crime_application.outgoings&.maintenance

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end
    end
  end
end
