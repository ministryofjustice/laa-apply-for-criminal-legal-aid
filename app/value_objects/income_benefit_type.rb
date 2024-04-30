class IncomeBenefitType < ValueObject
  VALUES = [
    CHILD = new(:child),
    WORKING_OR_CHILD_TAX_CREDIT = new(:working_or_child_tax_credit),
    INCAPACITY = new(:incapacity),
    INDUSTRIAL_INJURIES = new(:industrial_injuries_disablement),
    JSA = new(:jsa),
    OTHER = new(:other)
  ].freeze
end
