module Evidence
  module Rules
    class ExampleRule1 < Rule
      include Evidence::RuleDsl

      key :example1

      group :capital

      # Completely made-up rules
      client do |crime_application|
        crime_application.capital.has_premium_bonds == 'yes'
      end

      partner do |crime_application|
        crime_application.capital.partner_has_premium_bonds == 'yes'
      end
    end
  end
end
