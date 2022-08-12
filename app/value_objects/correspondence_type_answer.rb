class CorrespondenceTypeAnswer < ValueObject
  VALUES = [
    HOME_ADDRESS = new(:home_address),
    PROVIDERS_OFFICE_ADDRESS = new(:providers_office_address),
    OTHER_ADDRESS = new(:other_address)
  ].freeze
end
