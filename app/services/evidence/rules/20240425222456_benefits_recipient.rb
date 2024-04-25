module Evidence
  module Rules
    class BenefitsRecipient < Rule
      include Evidence::RuleDsl

      key :income_benefits_0b
      group :income

      client do |crime_application|
        crime_application.income&.has_no_income_benefits == 'no' ||
          crime_application.income_benefits.any?
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
