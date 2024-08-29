class PartnerInvolvementType < ValueObject
  VALUES = [
    VICTIM = new(:victim),
    PROSECUTION_WITNESS = new(:prosecution_witness),
    CODEFENDANT = new(:codefendant),
  ].freeze
end
