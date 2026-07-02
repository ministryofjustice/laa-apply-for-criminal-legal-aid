class FrozenIncomeOrAssetsSubjectType < ValueObject
  VALUES = [
    APPLICANT = new(:applicant),
    PARTNER = new(:partner),
    APPLICANT_AND_PARTNER = new(:applicant_and_partner),
  ].freeze
end
