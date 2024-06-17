module Evidence
  module Rules
    class MaintenanceIncome < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 500.00

      key :income_maintenance_6
      group :income

      client do |_crime_application, applicant|
        MaintenanceEvidenceRequired.for(applicant)
      end

      partner do |_crime_application, partner|
        MaintenanceEvidenceRequired.for(partner)
      end
    end
  end

  class MaintenanceEvidenceRequired
    def self.for(person)
      maintenance = person.income_payments.maintenance
      return false unless maintenance

      maintenance.prorated_monthly.to_f > Rules::MaintenanceIncome::THRESHOLD
    end
  end
end
