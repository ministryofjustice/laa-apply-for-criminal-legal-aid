module Steps
  module Income
    class BusinessFinancialsForm < Steps::BaseFormObject
      attribute :turnover, :amount_and_frequency, default: {}
      attribute :drawings, :amount_and_frequency, default: {}
      attribute :profit, :amount_and_frequency, default: {}

      delegate(:amount, :amount=, :frequency, :frequency=, to: :turnover, prefix: true)
      delegate(:amount, :amount=, :frequency, :frequency=, to: :drawings, prefix: true)
      delegate(:amount, :amount=, :frequency, :frequency=, to: :profit, prefix: true)

      validates(
        :turnover_amount, :drawings_amount, :profit_amount,
        presence: true, numericality: true
      )

      validates(
        :turnover_frequency, :drawings_frequency, :profit_frequency,
        inclusion: { in: PaymentFrequencyType.values }
      )

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end
    end
  end
end
