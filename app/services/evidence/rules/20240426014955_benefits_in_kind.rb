module Evidence
  module Rules
    class BenefitsInKind < Rule
      include Evidence::RuleDsl

      key :income_noncash_benefit_4
      group :income

      # TODO: Awaiting client implementation
      client do |_crime_application|
        false
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
