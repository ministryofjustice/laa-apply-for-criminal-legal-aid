module Evidence
  module Rules
    class PremiumBonds < Rule
      include Evidence::RuleDsl

      key :capital_premium_bonds_21
      group :capital

      client do |crime_application|
        if crime_application.capital
          crime_application.capital.has_premium_bonds == 'yes'
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
