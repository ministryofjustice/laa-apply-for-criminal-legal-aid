module SubmissionSerializer
  module Definitions
    class Deduction < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.deduction_type deduction_type
          json.amount amount_before_type_cast
          json.frequency frequency.respond_to?(:value) ? frequency.to_s : frequency
          json.details details
        end
      end
    end
  end
end
