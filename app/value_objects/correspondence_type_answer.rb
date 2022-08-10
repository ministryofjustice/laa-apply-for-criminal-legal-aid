class CorrespondenceTypeAnswer < ValueObject
  VALUES = [
    HOME_ADDRESS = new(:home_address),
    PROVIDERS_OFFICE_ADDRESS = new(:providers_office_address),
    OTHER_ADDRESS = new(:other_address)
  ].freeze

  def self.values
    VALUES
  end

  def home_address?
    value == :home_address
  end

  def providers_office_address?
    value == :providers_office_address
  end

  def other_address?
    value == :other_address
  end
end
