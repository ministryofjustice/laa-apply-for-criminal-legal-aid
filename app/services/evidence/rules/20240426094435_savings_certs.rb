module Evidence
  module Rules
    class SavingsCerts < Rule
      include Evidence::RuleDsl

      key :capital_savings_certs_22
      group :capital

      client do |crime_application|
        crime_application.capital&.client_national_savings_certificates.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_national_savings_certificates.present?
      end
    end
  end
end
