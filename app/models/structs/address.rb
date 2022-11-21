module Structs
  class Address < ApplicationStruct
    attribute :address_line_one, StructTypes::String
    attribute? :address_line_two, StructTypes::String
    attribute :city, StructTypes::String
    attribute :country, StructTypes::String
    attribute :postcode, StructTypes::String
  end
end
