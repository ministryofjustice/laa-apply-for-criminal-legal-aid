module SubmissionSerializer
  module Sections
    class ProviderDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.provider_details do
            # We don't know yet the attributes, TBD.
            json.merge!({})
          end
        end
      end
    end
  end
end
