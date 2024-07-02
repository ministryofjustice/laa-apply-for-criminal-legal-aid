class SubjectType < ValueObject
  VALUES = [
    APPLICANT = new(:applicant),
    APPLICANT_AND_PARTNER = new(:applicant_and_partner),
    APPLICANT_OR_PARTNER = new(:applicant_or_partner),
    PARTNER = new(:partner),
  ].freeze

  def to_param
    return 'client' if applicant?

    value
  end
end
