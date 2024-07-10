module Steps
  module Income
    class BusinessSalaryOrRemunerationForm < Steps::BaseFormObject
      attribute :salary, :amount_and_frequency
      validates :salary, payment: true

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
