module Passporting
  class MeansPassporter < BasePassporter
    def call
      return passported? if resubmission?
      return true if appeal_no_changes?

      means_passport = []

      means_passport << MeansPassportType::ON_NOT_MEANS_TESTED if app_not_means_tested?
      means_passport << MeansPassportType::ON_AGE_UNDER18      if applicant_under18?
      means_passport << MeansPassportType::ON_BENEFIT_CHECK    if benefit_check_passed?

      crime_application.update(means_passport:)

      passported?
    end

    def passported?
      not_means_tested? || age_passported? || benefit_check_passported?
    end

    def not_means_tested?
      app_not_means_tested?
    end

    # Age based passporting persists on resubmission
    def age_passported?
      return passported_on?(MeansPassportType::ON_AGE_UNDER18) if resubmission?

      applicant_under18?
    end

    def benefit_check_passported?
      benefit_check_passed?
    end

    def passport_types_collection
      crime_application.means_passport
    end

    private

    def app_not_means_tested?
      return false unless FeatureFlags.non_means_tested.enabled?
      return true if crime_application.is_means_tested == 'no'

      false
    end

    def applicant_under18?
      FeatureFlags.u18_means_passport.enabled? && super
    end

    def benefit_check_passed?
      applicant.benefit_check_result.present?
    end

    def appeal_no_changes?
      return false unless crime_application.case

      (crime_application.case.case_type == 'appeal_to_crown_court') &&
        (crime_application.case.appeal_financial_circumstances_changed == 'no')
    end
  end
end
