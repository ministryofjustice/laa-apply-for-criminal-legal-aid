module Steps
  module Income
    class BusinessAdditionalOwnersForm < Steps::BaseFormObject
      attribute :has_additional_owners, :value_object, source: YesNoAnswer
      attribute :additional_owners, :string

      validates :has_additional_owners, inclusion: { in: YesNoAnswer.values }
      validates :additional_owners, presence: true, if: -> { has_additional_owners&.yes? }

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
