module ClientDetails
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :kase, :crime_application, to: :record

    # Adds the error to the first step name a user would need to go to
    # fix the issue.

    def validate # rubocop:disable Metrics/AbcSize:
      errors.add(:details, :blank) unless applicant_details_complete?
      errors.add(:case_type, :blank) unless case_type_complete?
      errors.add(:residence_type, :blank) unless address_complete?
      errors.add(:has_nino, :blank) unless has_nino_complete?
      errors.add(:benefit_type, :blank) unless passporting_complete?

      errors.add :base, :incomplete_records unless errors.empty?
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

    def passporting_complete?
      return true if applicant.benefit_type == 'none'
      return true if evidence_of_passporting_means_forthcoming?

      Passporting::MeansPassporter.new(crime_application).call
    end

    def has_nino_complete?
      return false if applicant.has_nino.blank?
      return true if applicant.has_nino == 'no'

      applicant.nino.present?
    end

    alias crime_application record
  end
end
