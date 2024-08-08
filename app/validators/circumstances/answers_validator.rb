module Circumstances
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def applicable?
      crime_application.cifc?
    end

    def complete?
      validate
      errors.empty?
    end

    def validate
      return unless applicable?

      errors.add(:pre_cifc_reference_number, :blank) if crime_application.pre_cifc_reference_number.blank?
      errors.add(:pre_cifc_maat_id, :blank) if maat_id_blank?
      errors.add(:pre_cifc_usn, :blank) if usn_blank?
      errors.add(:pre_cifc_reason) if crime_application.pre_cifc_reason.blank?
    end

    def circumstances_complete?
      return true unless applicable?
      return false if crime_application.pre_cifc_reference_number.blank?
      return false if maat_id_blank? && usn_blank?
      return false if crime_application.pre_cifc_reason.blank?

      true
    end

    private

    def maat_id_blank?
      return false if crime_application.pre_cifc_reference_number.blank?

      crime_application.pre_cifc_reference_number == 'pre_cifc_maat_id' &&
        crime_application.pre_cifc_maat_id.blank?
    end

    def usn_blank?
      return false if crime_application.pre_cifc_reference_number.blank?

      crime_application.pre_cifc_reference_number == 'pre_cifc_usn' &&
        crime_application.pre_cifc_usn.blank?
    end
  end
end
