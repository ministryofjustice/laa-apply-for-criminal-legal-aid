module Steps
  module Income
    class IncomePaymentFieldsetForm < Steps::BaseFormObject
      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :integer
      attribute :frequency, :string
      attribute :details, :string

      validates :amount_in_pounds, presence: true, numericality: {
        greater_than: 0
      }

      validates :payment_types, presence: true, inclusion: { in: :payment_types }
      validates :frequency, presence: true, inclusion: { in: :frequencies }

      def payment_types
        IncomePaymentType.values.map(&:to_s) - ['none']
      end

      def frequencies
        PaymentFrequencyType.values.map(&:to_s)
      end

      def amount_in_pounds
        return unless amount

        amount_in_pounds = amount.dup / 100.0
        helpers.number_with_precision(amount_in_pounds, precision: 2)
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

      def helpers
        ActionController::Base.helpers
      end
    end
  end
end
