class RelationshipToPartnerType < ValueObject
  VALUES = [
    MARRIED_OR_CIVIL = new(:married_or_civil),
    LIVING_TOGETHER = new(:living_together),
    NOT_SAYING = new(:not_saying),
  ].freeze
end
