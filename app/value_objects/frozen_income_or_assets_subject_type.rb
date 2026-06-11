class FrozenIncomeOrAssetsSubjectType < ValueObject
  VALUES = [
    CLIENT = new(:client),
    PARTNER = new(:partner),
    CLIENT_AND_PARTNER = new(:client_and_partner),
  ].freeze
end
