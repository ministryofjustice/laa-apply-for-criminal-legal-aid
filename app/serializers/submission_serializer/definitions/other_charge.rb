module SubmissionSerializer
  module Definitions
    class OtherCharge < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.charge charge
          json.hearing_court_name hearing_court_name
          json.next_hearing_date next_hearing_date
        end
      end
    end
  end
end
