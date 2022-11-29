module SubmissionSerializer
  module Sections
    class ProviderDetails < Sections::BaseSection
      # This is an example of how we could, based on the application
      # record schema version, dynamically show/hide JSON sections
      def min_version
        1.1
      end

      # :nocov:
      def to_builder
        Jbuilder.new do |json|
          json.provider_details do
            json.firm 'Firm'
            json.office '2M012V'
            json.email 'firm@example.com'
          end
        end
      end
      # :nocov:
    end
  end
end
