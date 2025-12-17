module ClientDetails
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def complete?
      validate
      errors.empty?
    end

    def applicable?
      true
    end

    # Adds the error to the first step name a user would need to go to fix the issue.
    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      errors.add(:details, :blank) unless applicant_details_complete?
      errors.add(:case_type, :blank) unless case_type_complete?
      errors.add(:residence_type, :blank) unless address_complete?
      AppealDetails::AnswersValidator.new(record).validate
      errors.add(:has_nino, :blank) unless has_nino_complete?
      errors.add(:has_partner, :blank) unless has_partner_complete?
      errors.add(:relationship_status, :blank) unless relationship_status_complete?

      errors.add :base, :incomplete_records unless errors.empty?
    end

    def address_complete?
      return true if appeal_no_changes?
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
      return true if non_means_tested?
      return false unless kase

      kase.case_type.present?
    end

    def has_nino_complete?
      return true if age_passported? || appeal_no_changes?
      return false if applicant.has_nino.blank? && applicant.has_arc.blank?
      return true if applicant.has_nino == 'no'

      nino_complete? || applicant.arc.present?
    end

    def nino_complete?
      # Supplying a NINO is not mandatory for non means applications
      return true if non_means_tested? && applicant.has_nino == 'yes'

      applicant.nino.present?
    end

    def has_partner_complete?
      return true if partner_information_not_required?

      record.partner_detail&.has_partner.present?
    end

    def relationship_status_complete?
      return true if partner_information_not_required?
      return true if record.partner_detail&.has_partner == 'yes'

      record.partner_detail&.has_partner == 'no' && record.partner_detail&.relationship_status.present?
    end

    alias crime_application record
  end
end
