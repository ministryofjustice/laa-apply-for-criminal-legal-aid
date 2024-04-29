module Evidence
  module Rules
    class NationalInsuranceNumber < Rule
      include Evidence::RuleDsl

      key :national_insurance_32
      group :none

      client do |crime_application|
        crime_application&.applicant_requires_nino_evidence? || false
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
