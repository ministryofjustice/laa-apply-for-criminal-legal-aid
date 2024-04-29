module Evidence
  module Rules
    class RestraintOrFreezingOrder < Rule
      include Evidence::RuleDsl

      key :restraint_freezing_order_31
      group :none

      client do |crime_application|
        crime_application.capital&.has_frozen_income_or_assets == 'yes' ||
          crime_application.income&.has_frozen_income_or_assets == 'yes'
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
