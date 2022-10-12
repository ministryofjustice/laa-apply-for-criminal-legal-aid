module Steps
  module Case
    class DateStampForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use it to advance in the decision tree.
      def persist!
        true
      end
    end
  end
end
