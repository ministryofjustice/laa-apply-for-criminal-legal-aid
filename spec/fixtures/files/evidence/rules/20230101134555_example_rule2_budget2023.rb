module Evidence
  module Rules
    class ExampleRule2Budget2023 < Rule
      include Evidence::RuleDsl

      key :example2
      group :outgoings

      # Completely made-up rules
      client do |crime_application|
        crime_application.respond_to?(:outgoings) &&
          crime_application.outgoings.housing_payment_type == 'rent'
      end

      partner do |_crime_application|
        false
      end
    end
  end
end
