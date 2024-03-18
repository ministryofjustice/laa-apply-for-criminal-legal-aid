module SubmissionSerializer
  module Definitions
    class NationalSavingsCertificate < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.holder_number holder_number
          json.certificate_number certificate_number
          json.value value_before_type_cast
          json.ownership_type ownership_type
        end
      end
    end
  end
end
