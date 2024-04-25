module Evidence
  module Rules
    class NationalInsuranceProof < Rule
      include Evidence::RuleDsl

      key :national_insurance_32

      group :none

      # :nocov:
      other do |crime_application|
        crime_application&.applicant&.has_nino == 'yes'
      end
      # :nocov:
    end
  end
end
