module Evidence
  module Rules
    class BenefitsRecipient < Rule
      include Evidence::RuleDsl

      key :income_benefits_0b
      group :income

      client do |crime_application|
        status = crime_application.applicant&.benefit_check_status
        undetermined_or_unavailable = status.present? && (BenefitCheckStatus.new(status).undetermined? ||
          BenefitCheckStatus.new(status).no_record_found? || BenefitCheckStatus.new(status).checker_unavailable?)

        benefit_evidence_forthcoming = crime_application.applicant&.has_benefit_evidence == 'yes'

        crime_application.means_passport.empty? && undetermined_or_unavailable && benefit_evidence_forthcoming
      end

      partner do |crime_application|
        status = crime_application.partner&.benefit_check_status
        undetermined_or_unavailable = status.present? && (BenefitCheckStatus.new(status).undetermined? ||
          BenefitCheckStatus.new(status).no_record_found? || BenefitCheckStatus.new(status).checker_unavailable?)

        benefit_evidence_forthcoming = crime_application.partner&.has_benefit_evidence == 'yes'

        crime_application.means_passport.empty? && undetermined_or_unavailable && benefit_evidence_forthcoming
      end
    end
  end
end
