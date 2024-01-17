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

      def self.build(income_payment, crime_application: nil)
        #puts "===>RECORD: #{income_payment.inspect}"
        # if (matches = income_payment.payment_type.to_s.match(%r{^\["\w*"\]$}))
        #   income_payment.payment_type = matches[1]
        #   puts "===> REGEX MATCHED! `#{income_payment.payment_type}`"
        # end

        super(income_payment, crime_application:)
      end

      # def payment_type=(val)
      #   #val = ((JSON.parse(val) rescue nil) || val)
      #   puts "VAL WAS: #{val}"
      #   self['payment_type'] = val
      # end

      # def types=(ary)
      #   super(ary.compact_blank) if ary
      # end

      # def validate_types
      #   errors.add(:types, :invalid) if (types - IncomePaymentType.values.map(&:to_s)).any?
      # end

      # Needed for `#fields_for` to render the uuids as hidden fields
      # def persisted?
      #   id.present?
      # end
    end
  end
end
