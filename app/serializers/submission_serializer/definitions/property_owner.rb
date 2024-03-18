module SubmissionSerializer
  module Definitions
    class PropertyOwner < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name name
          json.relationship relationship
          json.custom_relationship custom_relationship
          json.percentage_owned percentage_owned&.to_f
        end
      end
    end
  end
end
