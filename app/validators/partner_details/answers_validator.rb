module PartnerDetails
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def applicable?
      return false unless record
      return false if applicant&.under18? || not_means_tested? || appeal_no_changes?

      record.has_partner != 'no'
    end

    def complete?
      return false unless record

      validate
      errors.empty?
    end

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return unless applicable?

      errors.add(:relationship_to_partner, :incomplete) if record.relationship_to_partner.blank?
      errors.add(:details, :blank) unless partner_details_complete?
      errors.add(:involved_in_case, :incomplete) if record.involved_in_case.blank?
      errors.add(:involvement_in_case, :incomplete) if record.involvement_in_case.blank?
      errors.add(:nino, :incomplete) unless nino?
      errors.add(:conflict_of_interest, :incomplete) unless conflict_of_interest?

      if include_partner_in_means_assessment?
        errors.add(:has_same_address_as_client, :incomplete) unless same_address?
        errors.add(:home_address, :incomplete) unless address?
      end

      errors.add(:base, :incomplete_records) if errors.present?
    end

    private

    def partner_details_complete?
      return false unless partner

      partner.values_at(
        :date_of_birth, :first_name, :last_name,
      ).all?(&:present?)
    end

    def nino?
      return true unless include_partner_in_means_assessment?
      return true if crime_application.partner&.has_nino == 'no'

      crime_application.partner&.nino.present? || crime_application.partner&.arc.present?
    end

    def address?
      return true unless include_partner_in_means_assessment?

      record.has_same_address_as_client == 'no' ? crime_application.partner&.home_address.present? : true
    end

    def same_address?
      return true unless include_partner_in_means_assessment?

      record.has_same_address_as_client.present?
    end

    def conflict_of_interest?
      record.involvement_in_case == 'codefendant' ? record.conflict_of_interest.present? : true
    end
  end
end
