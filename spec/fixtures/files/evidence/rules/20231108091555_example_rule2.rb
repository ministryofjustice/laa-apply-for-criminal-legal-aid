module Evidence
  module Rules
    class ExampleRule2 < Rule
      include Evidence::RuleDsl

      key :example2
      archived true

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
