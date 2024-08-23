module Passporting
  class MeansPassporter < BasePassporter
    include TypeOfMeansAssessment

    def call
      passported?
    end

    def means_passport
      return @means_passport if @means_passport

      passport = []
      passport << MeansPassportType::ON_NOT_MEANS_TESTED if app_not_means_tested?
      passport << MeansPassportType::ON_AGE_UNDER18      if age_passported?
      passport << MeansPassportType::ON_BENEFIT_CHECK    if benefit_check_passed?

      @means_passport = passport
    end
    alias passport_types_collection means_passport

    def passported?
      not_means_tested? || age_passported? || benefit_check_passported?
    end

    def not_means_tested?
      app_not_means_tested?
    end

    def age_passported?
      parent_was_age_passported? || applicant_under18?
    end

    def parent_was_age_passported?
      return false unless resubmission?
      return false if crime_application.means_passport.blank?

      crime_application.means_passport.include?(MeansPassportType::ON_AGE_UNDER18.to_s)
    end

    def benefit_check_passported?
      benefit_check_passed?
    end

    private

    def app_not_means_tested?
      return false unless FeatureFlags.non_means_tested.enabled?

      crime_application.is_means_tested == 'no'
    end

    def applicant_under18?
      FeatureFlags.u18_means_passport.enabled? && super
    end

    def benefit_check_passed?
      benefit_check_subject.benefit_check_result.present?
    end
  end
end
