module PartnerDetails
  class AnswersValidator
    attr_reader :record, :crime_application

    delegate :errors, to: :record

    def initialize(crime_application)
      @crime_application = crime_application
      @record = crime_application.partner_detail
    end

    def validate
      return unless applicable?
      return if complete?

      errors.add :partner_details, :incomplete
      errors.add :base, :incomplete_records
    end

    def applicable?
      crime_application.client_has_partner == 'yes'
    end

    def complete?
      return false unless record
      return true if crime_application.client_has_partner == 'no' && record.relationship_status.present?

      required = [
        record.relationship_to_partner,
        crime_application.partner&.first_name,
        crime_application.partner&.last_name,
        crime_application.partner&.date_of_birth,
        record.involvement_in_case,
      ].map(&:present?).all?(true)

      has_nino = crime_application.partner&.has_nino == 'yes' ? crime_application.partner.nino.present? : true
      has_address = record.has_same_address_as_client == 'no' ? crime_application.partner&.home_address.present? : true

      has_same_address = record.involvement_in_case == 'none' || record.conflict_of_interest == 'no' ? record.has_same_address_as_client.present? : true
      has_conflict_of_interest = record.involvement_in_case == 'codefendant' ? record.conflict_of_interest.present? : true

      required && has_nino && has_address && has_same_address && has_conflict_of_interest
    end
  end
end
