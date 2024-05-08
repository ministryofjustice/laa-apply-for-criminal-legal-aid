module TypeOfMeansAssessment
  extend ActiveSupport::Concern

  delegate :applicant, :kase, :income, :outgoings, :income_payments, :income_benefits, :capital, to: :crime_application

  def requires_means_assessment?
    return false unless FeatureFlags.means_journey.enabled?
    return false if Passporting::MeansPassporter.new(crime_application).call

    !evidence_of_passporting_means_forthcoming?
  end

  def requires_full_means_assessment?
    return false unless requires_means_assessment?

    if income_below_threshold? && no_frozen_assets?
      !(summary_only? || (no_property? && no_savings?))
    else
      true
    end
  end

  def requires_full_capital?
    return false unless kase&.case_type

    [
      CaseType::EITHER_WAY,
      CaseType::INDICTABLE,
      CaseType::ALREADY_IN_CROWN_COURT
    ].include?(CaseType.new(kase.case_type))
  end

  def evidence_of_passporting_means_forthcoming?
    return false unless has_passporting_benefit?

    benefit_evidence_forthcoming? || nino_forthcoming?
  end

  # Relevant when there's a passporting benefit but the NINO is unknown.
  # We consider the application to be passported on benefits until the
  # submission declaration.
  # However, if the applicant is not in court custody, submission will be
  # blocked until the NINO or benefit evidence is provided.
  def nino_forthcoming?
    applicant.has_nino == 'no' && applicant.will_enter_nino == 'no'
  end

  def benefit_evidence_forthcoming?
    applicant.has_benefit_evidence == 'yes'
  end

  private

  def has_passporting_benefit?
    BenefitType.passporting.include?(BenefitType.new(applicant.benefit_type.to_s))
  end

  def summary_only?
    kase.case_type == CaseType::SUMMARY_ONLY.to_s
  end

  def no_property?
    income.client_owns_property == 'no'
  end

  def no_savings?
    income.has_savings == 'no'
  end

  def no_frozen_assets?
    income.has_frozen_income_or_assets == 'no'
  end

  def income_below_threshold?
    income&.income_above_threshold == 'no'
  end
end
