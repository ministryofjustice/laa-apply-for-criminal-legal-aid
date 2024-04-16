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
        self.case.update(
          attributes
        )
      end

      def before_save
        self.appeal_maat_id = nil unless maat_id_selected?
        self.appeal_usn = nil unless usn_selected?
      end
    end
  end
end
