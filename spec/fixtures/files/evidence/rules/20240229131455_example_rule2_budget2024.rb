module Evidence
  module Rules
    class ExampleRule2Budget2024 < Rule
      include Evidence::RuleDsl

      key :example2

      group :outgoings

      # Completely made-up rules
      client do |crime_application|
        crime_application.is_means_tested? &&
          crime_application.applicant.has_nino == 'yes'
      end
    end
  end
end
