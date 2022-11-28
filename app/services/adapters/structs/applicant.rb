module Adapters
  module Structs
    class Applicant < BaseStructAdapter
      # NOTE: for MVP this is always true, as we are doing
      # screening of applicants with DWP. This will change
      # post-MVP but we don't know yet how exactly.
      def passporting_benefit
        true
      end
    end
  end
end
