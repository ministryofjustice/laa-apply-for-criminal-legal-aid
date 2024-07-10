module Steps
  module Income
    class BusinessTotalIncomeShareSalesForm < Steps::BaseFormObject
      attribute :total_income_share_sales, :amount_and_frequency
      validates :total_income_share_sales, payment: true

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
