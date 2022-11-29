module SubmissionSerializer
  module Definitions
    class Offence < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name offence.name
          json.offence_class offence.offence_class
          json.dates offence_dates.map(&:date)
        end
      end
    end
  end
end
