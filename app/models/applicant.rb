class Applicant < Person
  def has_passporting_benefit?
    BenefitType.passporting.map(&:value).include?(benefit_type&.to_sym)
  end
end
