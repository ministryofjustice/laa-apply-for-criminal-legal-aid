module SubmissionSerializer
  module Definitions
    class Offence < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name offence_name
          json.offence_class offence_class
          json.dates do
            json.merge! offence_dates.as_json(only: [:date_from, :date_to])
          end
        end
      end
    end
  end
end
