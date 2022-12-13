module Steps
  module Shared
    class NoOpForm < Steps::BaseFormObject
      # NOTE: steps using this form do not persist anything to DB.
      # It is only used to advance in the decision tree.
      # Normally used through the `Steps::NoOpAdvanceStep` concern.
      #
      def persist!
        true
      end
    end
  end
end
