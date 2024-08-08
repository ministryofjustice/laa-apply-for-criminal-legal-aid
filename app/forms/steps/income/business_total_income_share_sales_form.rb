module Steps
  module Income
    class BusinessTotalIncomeShareSalesForm < Steps::BaseFormObject
      attribute :total_income_share_sales, :amount_and_frequency, default: {}
      delegate(:amount, :amount=, to: :total_income_share_sales, prefix: true)

      validates :total_income_share_sales_amount, presence: true, numericality: true

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end

      def before_save
        total_income_share_sales.frequency = PaymentFrequencyType::ANNUALLY
      end
    end
  end
end
