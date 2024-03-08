class RelationshipType < ValueObject
  VALUES = [
    BUSINESS_ASSOCIATES = new(:business_associates),
    EX_PARTNER = new(:ex_partner),
    FAMILY_MEMBERS = new(:family_members),
    FRIENDS = new(:friends),
    HOUSE_BUILDER = new(:house_builder),
    HOUSING_ASSOCIATION = new(:housing_association),
    LOCAL_AUTHORITY = new(:local_authority),
    PARTNER_WITH_A_CONTRARY_INTEREST = new(:partner_with_a_contrary_interest),
    PROPERTY_COMPANY = new(:property_company),
  ].freeze
end
