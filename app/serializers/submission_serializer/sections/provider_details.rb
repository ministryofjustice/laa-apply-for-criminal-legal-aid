module SubmissionSerializer
  module Sections
    class ProviderDetails < Sections::BaseSection
      # :nocov:
      def to_builder
        Jbuilder.new do |json|
          json.provider_details nil
        end
      end
      # :nocov:
    end
  end
end
