module Evidence
  module Rules
    class RestraintOrFreezingOrder < Rule
      include Evidence::RuleDsl

      key :restraint_freezing_order_31
      group :none

      client do |crime_application|
        MeansStatus.new(crime_application).has_frozen_assets?
      end

      partner do |crime_application|
        MeansStatus.new(crime_application).has_frozen_assets?
      end
    end
  end
end
