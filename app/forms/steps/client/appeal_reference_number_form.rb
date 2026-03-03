module Steps
  module Client
    class AppealReferenceNumberForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      MAAT_ID_REGEXP = /\A[0-9]{6,9}\z/

      attribute :appeal_reference_number, :string
      attribute :appeal_maat_id, :string
      attribute :appeal_usn, :string

      validates :appeal_reference_number, presence: true
      validates :appeal_maat_id, presence: true, if: :maat_id_selected?
      validates :appeal_usn, presence: true, if: :usn_selected?

      validates :appeal_maat_id,
                format: { with: MAAT_ID_REGEXP }, allow_blank: true

      private

      def maat_id_selected?
        appeal_reference_number == 'appeal_maat_id'
      end

      def usn_selected?
        appeal_reference_number == 'appeal_usn'
      end

      def persist!
        reset_home_address
        reset_correspondence_address
        crime_application.applicant.update(applicant_attributes_to_reset)

        self.case.update(
          attributes
        )
      end

      def before_save
        self.appeal_maat_id = nil unless maat_id_selected?
        self.appeal_usn = nil unless usn_selected?
      end

      def applicant_attributes_to_reset
        {
          'residence_type' => nil, 'correspondence_address_type' => nil, 'telephone_number' => nil, 'has_nino' => nil,
          'nino' => nil, 'has_arc' => nil, 'arc' => nil, 'will_enter_nino' => nil, 'benefit_type' => nil,
          'last_jsa_appointment_date' => nil, 'benefit_check_result' => nil, 'has_benefit_evidence' => nil
        }
      end

      # TODO: Duplicate of method in residence type form, is there somewhere this could live?
      def reset_home_address
        return unless crime_application.applicant.home_address?

        crime_application.applicant.home_address.destroy!
      end

      def reset_correspondence_address
        return unless crime_application.applicant.correspondence_address?

        crime_application.applicant.correspondence_address.destroy!
      end
    end
  end
end
