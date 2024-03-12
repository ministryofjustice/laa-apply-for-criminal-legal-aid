module SubmissionSerializer
  module Definitions
    class Property < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.property_type property_type
          json.house_type house_type
          json.custom_house_type custom_house_type
          json.size_in_acres size_in_acres
          json.usage usage
          json.bedrooms bedrooms
          json.value value_before_type_cast
          json.outstanding_mortgage outstanding_mortgage_before_type_cast
          json.percentage_applicant_owned percentage_applicant_owned
          json.percentage_partner_owned percentage_partner_owned
          json.is_home_address is_home_address
          json.has_other_owners has_other_owners
          json.address address
        end
      end
    end
  end
end
