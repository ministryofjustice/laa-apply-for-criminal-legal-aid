class OwnershipType < ValueObject
  VALUES = [
    APPLICANT = new(:applicant),
    APPLICANT_AND_PARTNER = new(:applicant_and_partner),
    PARTNER = new(:partner),
  ].freeze
end
