module SubmissionSerializer
  module Definitions
    class Address < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.lookup_id lookup_id
          json.address_line_one address_line_one
          json.address_line_two address_line_two
          json.city city
          json.country country
          json.postcode postcode
        end
      end
    end
  end
end
