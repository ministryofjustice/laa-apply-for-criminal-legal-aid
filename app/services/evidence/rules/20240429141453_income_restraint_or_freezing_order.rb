module Evidence
  module Rules
    class IncomeRestraintOrFreezingOrder < Rule
      include Evidence::RuleDsl

      key :income_restraint_freezing_order_31
      group :income

      client do |crime_application|
        crime_application.income&.has_frozen_income_or_assets == 'yes'
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
