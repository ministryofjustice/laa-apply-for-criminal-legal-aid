class BusinessType < ValueObject
  VALUES = [
    SELF_EMPLOYED = new(:self_employed),
    PARTNERSHIP = new(:partnership),
    DIRECTOR_OR_SHAREHOLDER = new(:director_or_shareholder),
  ].freeze
end
