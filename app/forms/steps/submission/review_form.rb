module Steps
  module Submission
    class ReviewForm < Steps::BaseFormObject
      private

      # NOTE: this step is not persisting anything to DB.
      # We only use it to advance in the decision tree.
      def persist!
        true
      end
    end
  end
end
