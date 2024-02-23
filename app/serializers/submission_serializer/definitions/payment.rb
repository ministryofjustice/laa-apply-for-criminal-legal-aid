module SubmissionSerializer
  module Definitions
    class Payment < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.payment_type payment_type
          json.amount amount_before_type_cast
          json.frequency frequency
          json.metadata metadata
        end
      end
    end
  end
end
