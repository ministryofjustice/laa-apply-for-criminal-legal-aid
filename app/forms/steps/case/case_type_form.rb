module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attribute :case_type

      validates :case_type, presence: true

      has_one_association :case
      alias kase case

      def choices
        CaseType.values
      end

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
