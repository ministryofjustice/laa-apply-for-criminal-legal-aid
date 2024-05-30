class RelationshipToPartnerType < ValueObject
  VALUES = [
    MARRIED_OR_PARTNERSHIP = new(:married_or_partnership),
    LIVING_TOGETHER = new(:living_together),
    NOT_SAYING = new(:prefer_not_to_say),
  ].freeze
end
