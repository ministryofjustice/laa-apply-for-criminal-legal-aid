module Evidence
  module Rules
    class CapitalRestraintOrFreezingOrder < Rule
      include Evidence::RuleDsl

      key :capital_restraint_freezing_order_31
      group :capital

      client do |crime_application|
        crime_application.capital&.has_frozen_income_or_assets == 'yes'
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
