module Evidence
  module Rules
    class CouncilTaxPayments < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 500.00

      key :outgoings_counciltax_12
      group :outgoings

      client do |crime_application|
        payment = crime_application.outgoings&.council_tax

        payment.present? && payment.prorated_monthly.to_f > THRESHOLD
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
