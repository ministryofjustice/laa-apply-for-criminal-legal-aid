class BeforeOrAfterTax < ValueObject
  VALUES = [
    BEFORE = new(:before_tax),
    AFTER = new(:after_tax)
  ].freeze
end
