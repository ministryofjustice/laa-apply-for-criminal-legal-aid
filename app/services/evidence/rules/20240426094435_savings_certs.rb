module Evidence
  module Rules
    class SavingsCerts < Rule
      include Evidence::RuleDsl

      key :capital_savings_certs_22
      group :capital

      client do |_crime_application, applicant|
        applicant.national_savings_certificates.any?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          partner.national_savings_certificates.any?
      end
    end
  end
end
