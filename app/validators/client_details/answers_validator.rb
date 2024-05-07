module ClientDetails
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :kase, :crime_application, :appeal_no_changes?, to: :record

    # Adds the error to the first step name a user would need to go to fix the issue.

    def validate
      errors.add(:details, :blank) unless applicant_details_complete?
      errors.add(:case_type, :blank) unless case_type_complete?

      applicant.under18? ? validate_u18 : validate_other

      errors.add :base, :incomplete_records unless errors.empty?
    end

    def validate_u18
      errors.add(:residence_type, :blank) unless address_complete?
    end

    def validate_other
      return if appeal_no_changes?

      errors.add(:residence_type, :blank) unless address_complete?
      errors.add(:has_nino, :blank) unless has_nino_complete?
    end

    def address_complete?
      return false if applicant.residence_type.blank?

      case applicant.correspondence_address_type
      when CorrespondenceType::HOME_ADDRESS.to_s
        applicant.home_address?
      when CorrespondenceType::OTHER_ADDRESS.to_s
        applicant.correspondence_address?
      when CorrespondenceType::PROVIDERS_OFFICE_ADDRESS.to_s
        true
      else
        false
      end
    end

    def applicant_details_complete?
      applicant.values_at(
        :date_of_birth, :first_name, :last_name,
      ).all?(&:present?)
    end

    def case_type_complete?
      return false unless kase

      kase.case_type.present?
    end

    def has_nino_complete?
      return false if applicant.has_nino.blank?
      return true if applicant.has_nino == 'no'

      applicant.nino.present?
    end

    alias crime_application record
  end
end
