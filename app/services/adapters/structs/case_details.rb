module Adapters
  module Structs
    class CaseDetails < BaseStructAdapter
      # TODO: finalise this in a separate PR
      def charges
        []
      end

      # rubocop:disable Naming/PredicateName
      def has_codefendants
        codefendants.any? ? YesNoAnswer::YES : YesNoAnswer::NO
      end
      # rubocop:enable Naming/PredicateName

      # FIXME: I think this should be included in the JSON document
      # For now, as we don't get it from the datastore, mock it
      def ioj_passport
        []
      end
    end
  end
end
