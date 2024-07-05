module Steps
  module Income
    class BusinessEmployeesForm < Steps::BaseFormObject
      attribute :has_employees, :value_object, source: YesNoAnswer
      attribute :number_of_employees, :integer

      validates :has_employees, inclusion: { in: YesNoAnswer.values }
      validates :number_of_employees, numericality: { greater_than: 0 }, if: -> { has_employees&.yes? }

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
