module Evidence
  module Rules
    class ExampleRule < Rule
      include Evidence::RuleDsl

      key :example_rule
      group :none
      archived true

      other do |crime_application|
        crime_application.id == "Example predicate: #{SecureRandom.hex}"
      end
    end
  end
end
