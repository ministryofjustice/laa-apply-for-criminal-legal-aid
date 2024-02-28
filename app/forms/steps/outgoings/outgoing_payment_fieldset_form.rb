module Steps
  module Outgoings
    class OutgoingPaymentFieldsetForm < Steps::BaseFormObject
      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :pence
      attribute :frequency, :string
      attribute :case_reference, :string

      validates :amount, numericality: {
        greater_than: 0
      }

      validates :payment_types, presence: true, inclusion: { in: :payment_types }
      validates :frequency, presence: true, inclusion: { in: :frequencies }

      validate :case_ref_when_legal_aid_contribution?

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end

      def persist!
        unless persisted?
          delete
          record.crime_application = crime_application
        end

        record.save!
      end

      def delete
        crime_application.outgoings_payments.find_by(payment_type:)&.delete
      end

      private

      def payment_types
        OutgoingsPaymentType::OTHER_PAYMENT_TYPES.map(&:to_s) - ['none']
      end

      def frequencies
        PaymentFrequencyType.values.map(&:to_s)
      end

      def case_ref_when_legal_aid_contribution?
        return true if payment_type == OutgoingsPaymentType::LEGAL_AID_CONTRIBUTION.to_s
        return true if case_reference.blank?

        errors.add(:case_reference)
      end
    end
  end
end
