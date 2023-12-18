module SubmissionSerializer
  module Definitions
    class Dependant < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.age age
        end
      end
    end
  end
end
