module Evidence
  module Rules
    class NationalInsuranceProof < Rule
      include Evidence::RuleDsl

      key :national_insurance_32
      group :none

      client do |crime_application|
        crime_application&.applicant&.has_nino == 'yes'
      end

      partner do |crime_application|
        true
      end
    end
  end
end
