module Steps
  module Income
    class BusinessNatureForm < Steps::BaseFormObject
      attribute :description, :string
      validates :description, presence: true

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
