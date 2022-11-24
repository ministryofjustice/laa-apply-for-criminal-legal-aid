module SubmissionSerializer
  module Definitions
    class Address < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.address_line_one address_line_one
          json.address_line_two address_line_two
        end
      end
    end
  end
end
