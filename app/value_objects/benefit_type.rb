class BenefitType < ValueObject
  VALUES = [
    UNIVERSAL_CREDIT = new(:universal_credit),
    GUARANTEE_PENSION = new(:guarantee_pension),
    JSA = new(:jsa),
    ESA = new(:esa),
    INCOME_SUPPORT = new(:income_support),
    NONE = new(:none),
  ].freeze

  def self.passporting
    VALUES.excluding([NONE])
  end
end
