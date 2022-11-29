module SubmissionSerializer
  module Definitions
    class Offence < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name offence_name
          json.offence_class nil
          json.dates offence_dates.map(&:date)
        end
      end
    end
  end
end
