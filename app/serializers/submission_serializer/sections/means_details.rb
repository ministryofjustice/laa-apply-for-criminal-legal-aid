module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          next unless income && requires_means_assessment?

          json.means_details do
            json.income_details IncomeDetails.new(crime_application).to_builder
            json.outgoings_details OutgoingsDetails.new(crime_application).to_builder
            json.capital_details CapitalDetails.new(crime_application).to_builder
          end
        end
      end
    end
  end
end
