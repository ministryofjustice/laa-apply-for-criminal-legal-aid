module Evidence
  module Rules
    class SelfAssessed < Rule
      include Evidence::RuleDsl

      key :income_p60_sa302_2
      group :income

      client do |crime_application|
        if crime_application.outgoings
          (crime_application.outgoings.income_tax_rate_above_threshold == 'yes') || false
        else
          false
        end
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
