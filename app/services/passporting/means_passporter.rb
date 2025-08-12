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
      # TODO: Should means_passport be set if evidence will be provided?

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
      age_passported_at_datestamp_or_now?
    end

    def benefit_check_passported?
      benefit_check_passed?
    end

    private

    def app_not_means_tested?
      crime_application.is_means_tested == 'no'
    end

    def benefit_check_passed?
      benefit_check_subject.dwp_response == 'Yes' || benefit_check_subject.benefit_check_result.present?
    end
  end
end
