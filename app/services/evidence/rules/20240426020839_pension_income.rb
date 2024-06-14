module Evidence
  module Rules
    class PrivatePensionIncome < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      # Note this is per month
      THRESHOLD = 1000.00

      key :income_private_pension_5
      group :income

      client do |_crime_application, applicant|
        PensionEvidenceRequired.for(applicant)
      end

      partner do |_crime_application, partner|
        PensionEvidenceRequired.for(partner)
      end
    end
  end

  class PensionEvidenceRequired
    def self.for(person)
      pension = person.income_payments.private_pension
      return false unless pension

      pension.prorated_monthly.to_f > Rules::PrivatePensionIncome::THRESHOLD
    end
  end
end
