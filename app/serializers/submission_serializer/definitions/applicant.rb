module SubmissionSerializer
  module Definitions
    class Applicant < Definitions::BaseDefinition
      # rubocop:disable Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.first_name first_name
          json.last_name last_name
          json.other_names other_names
          json.date_of_birth date_of_birth
          json.nino nino
          json.benefit_type benefit_type
          json.telephone_number telephone_number
          json.correspondence_address_type correspondence_address_type

          json.home_address Definitions::Address.generate(home_address)
          json.correspondence_address Definitions::Address.generate(correspondence_address)
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
