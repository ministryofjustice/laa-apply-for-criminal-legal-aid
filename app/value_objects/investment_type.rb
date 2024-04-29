class InvestmentType < ValueObject
  VALUES = [
    BOND = new(:bond),
    PEP = new(:pep),
    SHARE = new(:share),
    SHARE_ISA = new(:share_isa),
    STOCK = new(:stock),
    UNIT_TRUST = new(:unit_trust),
    OTHER = new(:other),
  ].freeze
end
