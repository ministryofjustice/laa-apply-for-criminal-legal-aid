module Evidence
  module Rules
    class BenefitsRecipient < Rule
      include Evidence::RuleDsl

      key :income_benefits_0b
      group :income

      client do |crime_application|
        status = crime_application.applicant&.benefit_check_status

        crime_application.means_passport.empty? &&
          status.present? && BenefitCheckStatus.new(status).undetermined?
      end

      partner do |crime_application|
        status = crime_application.partner&.benefit_check_status

        crime_application.means_passport.empty? &&
          status.present? && BenefitCheckStatus.new(status).undetermined?
      end
    end
  end
end
