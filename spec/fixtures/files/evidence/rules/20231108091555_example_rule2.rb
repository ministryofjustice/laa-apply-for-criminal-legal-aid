module Evidence
  module Rules
    class ExampleRule2 < Rule
      include Evidence::RuleDsl

      key :example2
      archived true

      group :outgoings

      # Completely made-up rules
      client do |crime_application|
        crime_application.responds_to?(:outgoings) &&
          crime_application.is_means_tested?
      end
    end
  end
end
