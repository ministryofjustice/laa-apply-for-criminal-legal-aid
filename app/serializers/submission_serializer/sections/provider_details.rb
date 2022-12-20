module SubmissionSerializer
  module Sections
    class ProviderDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.provider_details do
            json.office_code crime_application.office_code
          end
        end
      end
    end
  end
end
