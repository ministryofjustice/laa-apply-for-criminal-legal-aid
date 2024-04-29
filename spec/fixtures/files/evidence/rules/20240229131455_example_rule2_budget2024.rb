module Evidence
  module Rules
    class ExampleRule2Budget2024 < Rule
      include Evidence::RuleDsl

      key :example2

      group :outgoings

      # Completely made-up rules
      client do |crime_application|
        crime_application.respond_to?(:outgoings) &&
          crime_application.outgoings.housing_payment_type == 'mortgage' &&
          crime_application.applicant.has_nino == 'yes'
      end
    end
  end
end
