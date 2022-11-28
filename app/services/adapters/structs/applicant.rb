module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      # FIXME: I think this should be included in the JSON document
      # For now, as we don't get it from the datastore, mock it
      def passporting_benefit
        true
      end
    end
  end
end
