class ClientRelationshipStatusType < ValueObject
  VALUES = [
    SINGLE = new(:single),
    WIDOWED = new(:widowed),
    DIVORCED = new(:divorced),
    SEPARATED = new(:separated),
    NOT_SAYING = new(:prefer_not_to_say),
  ].freeze
end
