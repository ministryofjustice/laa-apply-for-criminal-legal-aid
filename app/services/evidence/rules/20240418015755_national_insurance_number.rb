module Evidence
  module Rules
    class NationalInsuranceNumber < Rule
      include Evidence::RuleDsl

      key :national_insurance_32
      group :none

      client do |crime_application|
        status = crime_application.applicant&.benefit_check_status
        income_benefits = crime_application.income&.client_income_benefits || []

        income_benefits.any? || (status.present? && BenefitCheckStatus.new(status).no_check_no_nino?)
      end

      partner do |crime_application|
        status = crime_application.partner&.benefit_check_status
        income_benefits = crime_application.income&.partner_income_benefits || []

        income_benefits.any? || (status.present? && BenefitCheckStatus.new(status).no_check_no_nino?)
      end
    end
  end
end
