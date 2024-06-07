module PartnerDetails
  class AnswersValidator < BaseAnswerValidator
    def validate
      return unless applicable?
      return if complete?

      # NOTE: partner_details refers to general partnership information, stored
      # in partner and partner_detail
      errors.add :partner_details, :incomplete
      errors.add :base, :incomplete_records
    end

    def applicable?
      crime_application.client_has_partner == 'yes'
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
    def complete?
      return false unless record
      return true if no_partner_complete?
      return false if no_partner_incomplete?

      [
        record.relationship_to_partner,
        crime_application.partner&.first_name,
        crime_application.partner&.last_name,
        crime_application.partner&.date_of_birth,
        record.involvement_in_case,
        nino?,
        conflict_of_interest?,
        same_address?,
        address?,
      ].map(&:present?).all?(true)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

    private

    def no_partner_complete?
      crime_application.client_has_partner == 'no' && record.relationship_status.present?
    end

    def no_partner_incomplete?
      crime_application.client_has_partner == 'no' && record.relationship_status.blank?
    end

    def nino?
      crime_application.partner&.has_nino == 'yes' ? crime_application.partner.nino.present? : true
    end

    def address?
      record.has_same_address_as_client == 'no' ? crime_application.partner&.home_address.present? : true
    end

    def same_address?
      return true unless record.involvement_in_case == 'none' || record.conflict_of_interest == 'no'

      record.has_same_address_as_client.present?
    end

    def conflict_of_interest?
      record.involvement_in_case == 'codefendant' ? record.conflict_of_interest.present? : true
    end
  end
end
