class InvolvementInCase < ValueObject
  VALUES = [
    VICTIM = new(:victim),
    PROSECUTION_WITNESS = new(:prosecution_witness),
    CODEFENDANT = new(:codefendant),
    NONE = new(:none)
  ].freeze
end
