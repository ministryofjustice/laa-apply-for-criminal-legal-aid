module Steps
  module Income
    class IncomePaymentFieldsetForm < Steps::BaseFormObject
      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :pence
      attribute :frequency, :string
      attribute :details, :string

      validates :amount, numericality: {
        greater_than: 0
      }

      validates :payment_types, presence: true, inclusion: { in: :payment_types }
      validates :frequency, presence: true, inclusion: { in: :frequencies }

      validate :details_only_when_other?

      def payment_types
        IncomePaymentType::OTHER_INCOME_PAYMENT_TYPES.map(&:to_s) - ['none']
      end

      def frequencies
        PaymentFrequencyType.values.map(&:to_s)
      end

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
        crime_application.income_payments.find_by(payment_type:)&.delete
      end

      private

      def details_only_when_other?
        if (payment_type == IncomePaymentType::OTHER.to_s) && details.blank?
          errors.add(:details, :blank)
        elsif (payment_type != IncomePaymentType::OTHER.to_s) && details.present?
          errors.add(:details, :invalid)
        end
      end
    end
  end
end
