module Steps
  module Income
    class IncomePaymentFieldsetForm < Steps::BaseFormObject

      attribute :id, :string
      attribute :payment_type, :string
      attribute :amount, :integer
      attribute :frequency, :string
      attribute :details, :string


      validates_presence_of :payment_type
      validates_presence_of :amount
      validates_presence_of :frequency

      def types=(ary)
        super(ary.compact_blank) if ary
      end

      def validate_types
        errors.add(:types, :invalid) if (types - IncomePaymentType.values.map(&:to_s)).any?
      end

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end
    end
  end
end
