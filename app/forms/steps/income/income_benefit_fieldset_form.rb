module Steps
  module Income
    class IncomeBenefitFieldsetForm < Steps::BaseFormObject
      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :integer # Save in pence
      attribute :frequency, :string
      attribute :details, :string

      validates :amount_in_pounds, numericality: {
        greater_than: 0
      }

      validates :payment_types, presence: true, inclusion: { in: :payment_types }
      validates :frequency, presence: true, inclusion: { in: :frequencies }

      validate :details_only_when_other?

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

      private

      def payment_types
        IncomeBenefitType.values.map(&:to_s) - ['none']
      end

      def frequencies
        PaymentFrequencyType.values.map(&:to_s)
      end

      def helpers
        ActionController::Base.helpers
      end

      def details_only_when_other?
        return true if payment_type == IncomeBenefitType::OTHER.to_s
        return true if details.blank?

        errors.add(:details)
      end
    end
  end
end
