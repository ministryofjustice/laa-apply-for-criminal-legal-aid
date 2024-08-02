module Steps
  module Income
    class BusinessSalaryOrRemunerationForm < Steps::BaseFormObject
      attribute :salary, :amount_and_frequency, default: {}
      delegate(:amount, :amount=, to: :salary, prefix: true)

      validates :salary_amount, presence: true, numericality: true

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end

      def before_save
        salary.frequency = PaymentFrequencyType::ANNUALLY
      end
    end
  end
end
