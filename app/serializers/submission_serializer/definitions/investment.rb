module SubmissionSerializer
  module Definitions
    class Investment < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.investment_type investment_type
          json.description description
          json.value value_before_type_cast
          json.holder holder
        end
      end
    end
  end
end
