class ResidenceType < ValueObject
  VALUES = [
    RENTED = new(:rented),
    TEMPORARY = new(:temporary),
    PARENTS = new(:parents),
    APPLICANT_OWNED = new(:applicant_owned),
    PARTNER_OWNED = new(:partner_owned),
    JOINT_OWNED = new(:joint_owned),
    SOMEONE_ELSE = new(:someone_else),
    NONE = new(:none),
  ].freeze

  def owned?
    [
      APPLICANT_OWNED,
      PARTNER_OWNED,
      JOINT_OWNED
    ].include?(self)
  end
end
