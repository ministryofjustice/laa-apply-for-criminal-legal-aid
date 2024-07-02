module Steps
  module Income
    class BusinessFinancialsForm < Steps::BaseFormObject
      attribute :turnover, :amount_and_frequency
      attribute :drawings, :amount_and_frequency
      attribute :profit, :amount_and_frequency

      validates :turnover, :drawings, :profit, payment: true

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def financials
        %i[turnover drawings profit]
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end
    end
  end
end
