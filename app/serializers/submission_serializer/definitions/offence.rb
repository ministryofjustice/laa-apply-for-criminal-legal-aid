module SubmissionSerializer
  module Definitions
    class Offence < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name offence_name
          json.offence_class offence_class
          json.dates offence_dates.pluck(:date)
        end
      end
    end
  end
end
