module Evidence
  module Rules
    class SalariedEmployee < Rule
      include Evidence::RuleDsl

      key :income_employed_0a
      group :income

      client do |crime_application|
        crime_application.income.present? && crime_application.income.client_employed?
      end

      partner do |crime_application|
        crime_application.income.present? && crime_application.income.partner_employed?
      end
    end
  end
end
