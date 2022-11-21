module Structs
  class Person < ApplicationStruct
    attribute :first_name, StructTypes::String
    attribute :last_name, StructTypes::String
    attribute? :other_names, StructTypes::String
    attribute :date_of_birth, StructTypes::JSON::Date
    attribute :nino, StructTypes::String

    attribute? :address, Address
    attribute? :correspondence_address, Address
    attribute :telephone_number, StructTypes::String
    attribute :correspondence_address_type, StructTypes::CorrespondenceAddressType
  end
end
