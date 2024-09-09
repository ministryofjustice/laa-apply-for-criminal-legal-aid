module Steps
  module Income
    class IncomePaymentFieldsetForm < Steps::BaseFormObject
      include FieldValidation

      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :pence
      attribute :frequency, :string
      attribute :details, :string

      validate { presence_with_payment_type :amount }
      validate { presence_with_payment_type :frequency }
      validate { numericality_with_payment_type(:amount, greater_than: 0) }

      validates :payment_types, presence: true, inclusion: { in: :payment_types }
      validates :frequency, inclusion: { in: :frequencies }

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
        crime_application.applicant.income_payments.find_by(payment_type:)&.delete
      end

      private

      def details_only_when_other?
        if (payment_type == IncomePaymentType::OTHER.to_s) && details.blank?
          errors.add(:details, :blank)
        elsif (payment_type != IncomePaymentType::OTHER.to_s) && details.present?
          errors.add(:details, :invalid)
        end
      end

      def presence_with_payment_type(attribute)
        return if send(attribute).present?

        errors.add(attribute, :blank, payment_type: payment_type_presentable&.downcase!)
      end

      def numericality_with_payment_type(attribute, greater_than:)
        numericality_errors = numericality(attribute, greater_than:)

        numericality_errors.each do |error|
          errors.add(attribute, error, payment_type: payment_type_presentable)
        end
      end

      def payment_type_presentable
        I18n.t(
          payment_type,
          scope: [:helpers, :label, :steps_income_income_payments_form, :types_options]
        )
      end
    end
  end
end
