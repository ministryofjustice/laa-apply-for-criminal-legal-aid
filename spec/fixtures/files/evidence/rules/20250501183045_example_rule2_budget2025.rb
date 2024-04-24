module Evidence
  module Rules
    class ExampleRule2Budget2025 < Rule
      include Evidence::RuleDsl

      key :example2
      archived true
      group :outgoings

      # Completely made-up rules
      client do |crime_application|
        crime_application.respond_to?(:outgoings) &&
          crime_application.outgoings.housing_payment_type == 'board_and_lodging'
      end
    end
  end
end
