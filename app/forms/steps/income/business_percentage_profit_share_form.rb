module Steps
  module Income
    class BusinessPercentageProfitShareForm < Steps::BaseFormObject
      attribute :percentage_profit_share, :decimal

      validates_numericality_of :percentage_profit_share, greater_than: 0.0,
                                less_than_or_equal_to: 100.0

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
