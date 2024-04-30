module Evidence
  module Rules
    class RentalIncome < Rule
      include Evidence::RuleDsl

      key :income_rent_8
      group :income

      client do |crime_application|
        crime_application.income_payments.rent.present?
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
