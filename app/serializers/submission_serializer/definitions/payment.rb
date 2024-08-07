module SubmissionSerializer
  module Definitions
    class Payment < Definitions::BaseDefinition
      def to_builder # rubocop:disable Metrics/AbcSize
        Jbuilder.new do |json|
          json.payment_type payment_type.respond_to?(:value) ? payment_type.to_s : payment_type
          # FIXME: should not need to do the before_type_cast thing
          # remove and confirm
          json.amount amount_before_type_cast
          json.frequency frequency.respond_to?(:value) ? frequency.to_s : frequency
          json.ownership_type respond_to?(:ownership_type) ? ownership_type : OwnershipType::APPLICANT.to_s
          json.metadata metadata
        end
      end
    end
  end
end
