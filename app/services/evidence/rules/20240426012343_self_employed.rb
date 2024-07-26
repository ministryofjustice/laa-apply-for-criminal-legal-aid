module Evidence
  module Rules
    class SelfEmployed < Rule
      include Evidence::RuleDsl

      key :income_selfemployed_3
      group :income

      client do |crime_application|
        crime_application.income.present? &&
          crime_application.income.client_self_employed?
      end

      partner do |crime_application|
        crime_application.income.present? &&
          crime_application.income.partner_self_employed?
      end
    end
  end
end
