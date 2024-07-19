module Steps
  module Circumstances
    class PreCifcReferenceNumberForm < Steps::BaseFormObject
      MAAT_ID_REGEXP = /\A[0-9]{6,9}\z/

      attribute :pre_cifc_reference_number, :string
      attribute :pre_cifc_maat_id, :string
      attribute :pre_cifc_usn, :string

      validates :pre_cifc_reference_number, presence: true
      validates :pre_cifc_maat_id, presence: true, if: :maat_id_selected?
      validates :pre_cifc_usn, presence: true, if: :usn_selected?

      validates :pre_cifc_maat_id,
                format: { with: MAAT_ID_REGEXP }, allow_blank: true

      private

      def maat_id_selected?
        pre_cifc_reference_number == 'pre_cifc_maat_id'
      end

      def usn_selected?
        pre_cifc_reference_number == 'pre_cifc_usn'
      end

      def persist!
        crime_application.update(attributes)
      end

      def before_save
        self.pre_cifc_maat_id = nil unless maat_id_selected?
        self.pre_cifc_usn = nil unless usn_selected?
      end
    end
  end
end
