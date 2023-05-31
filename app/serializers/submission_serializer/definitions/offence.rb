module SubmissionSerializer
  module Definitions
    class Offence < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.name offence_name
          json.offence_class offence.try(:offence_class)          # non-listed offences lack class
          json.passportable offence.try(:ioj_passport) || false   # non-listed offences lack passporting
          json.dates do
            json.merge! offence_dates.as_json(only: [:date_from, :date_to])
          end
        end
      end
    end
  end
end
