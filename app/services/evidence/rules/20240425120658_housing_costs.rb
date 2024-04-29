module Evidence
  module Rules
    class HousingCosts < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 500.00

      key :outgoings_housing_11
      group :outgoings

      client do |crime_application|
        costs = [
          crime_application.outgoings_payments.mortgage,
          crime_application.outgoings_payments.rent,
        ]

        total = costs.compact.sum { |x| x.prorated_monthly.to_f }

        total > THRESHOLD
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
