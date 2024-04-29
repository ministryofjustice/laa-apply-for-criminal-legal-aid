module Evidence
  module Rules
    class SavingsCerts < Rule
      include Evidence::RuleDsl

      key :capital_savings_certs_22
      group :capital

      client do |crime_application|
        if crime_application.capital
          crime_application.capital.has_national_savings_certificates == 'yes'
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
