module SubmissionSerializer
  module Definitions
    class Codefendant < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.first_name first_name
          json.last_name last_name
          json.conflict_of_interest conflict_of_interest
        end
      end
    end
  end
end
