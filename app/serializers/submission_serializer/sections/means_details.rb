module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.means_details do
            json.income_details do
              json.income_above_threshold crime_application.income_details&.income_above_threshold
            end
          end
        end
      end
    end
  end
end
