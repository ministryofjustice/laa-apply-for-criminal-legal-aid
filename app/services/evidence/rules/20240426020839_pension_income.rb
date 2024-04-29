module Evidence
  module Rules
    class PrivatePensionIncome < Rule
      include Evidence::RuleDsl

      # Note value in pounds, db pence/amounts are stored in pennies
      THRESHOLD = 1000.00

      key :income_private_pension_5
      group :income

      client do |crime_application|
        income = [
          crime_application.income_payments.private_pension,
        ]

        total = income.compact.sum { |x| x.prorated_monthly.to_f }

        total > THRESHOLD
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
