class BeforeOrAfterTax < ValueObject
  VALUES = [
    BEFORE = new(:before_tax),
    AFTER = new(:after_tax)
  ].freeze

  def as_json(_opts = nil)
    { value: }
  end
end
