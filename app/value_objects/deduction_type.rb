class DeductionType < ValueObject
  VALUES = [
    INCOME_TAX = new(:income_tax),
    NATIONAL_INSURANCE = new(:national_insurance),
    OTHER = new(:other),
  ].freeze
end
