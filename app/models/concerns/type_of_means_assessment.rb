module TypeOfMeansAssessment
  extend ActiveSupport::Concern

  delegate :applicant, :partner, :kase, :income, :outgoings, :income_payments, :income_benefits,
           :capital, :appeal_no_changes?, :partner_detail, to: :crime_application, allow_nil: true

  def requires_means_assessment?
    return false unless FeatureFlags.means_journey.enabled?
    return false if Passporting::MeansPassporter.new(crime_application).call
    return false if appeal_no_changes?

    !evidence_of_passporting_means_forthcoming?
  end

  def requires_full_means_assessment?
    return false unless requires_means_assessment?
    return true if income_above_threshold? || has_frozen_assets?

    !summary_only? && !(no_property? && no_savings?)
  end

  def requires_full_capital?
    return false unless kase&.case_type

    [
      CaseType::EITHER_WAY,
      CaseType::INDICTABLE,
      CaseType::ALREADY_IN_CROWN_COURT
    ].include?(CaseType.new(kase.case_type))
  end

  def include_partner_in_means_assessment?
    return false unless partner.present? || partner_detail.present?
    return true if partner_involvement_in_case == PartnerInvolvementType::NONE.to_s
    return false unless partner_involvement_in_case == PartnerInvolvementType::CODEFENDANT.to_s

    partner_conflict_of_interest == 'no'
  end

  def evidence_of_passporting_means_forthcoming?
    benefit_evidence_forthcoming? || nino_forthcoming?
  end

  # Relevant when there's a passporting benefit but the NINO is unknown.
  # We consider the application to be passported on benefits until the
  # submission declaration.
  # However, if the applicant is not in court custody, submission will be
  # blocked until the NINO or benefit evidence is provided.
  def nino_forthcoming?
    return false unless has_passporting_benefit?
    return false unless benefit_check_recipient.has_nino == 'no'
    return false if benefit_check_recipient.will_enter_nino == 'yes'

    benefit_check_recipient.will_enter_nino == 'no' || kase.is_client_remanded == 'yes'
  end

  def benefit_evidence_forthcoming?
    return false unless has_passporting_benefit?
    return false if benefit_check_recipient.nino.blank?

    benefit_check_recipient.has_benefit_evidence == 'yes'
  end

  def means_assessment_as_benefit_evidence?
    return false unless has_passporting_benefit?
    return false if benefit_check_recipient.nino.blank?

    benefit_check_recipient.has_benefit_evidence == 'no'
  end

  def benefit_check_recipient
    return applicant unless include_partner_in_means_assessment?
    return applicant unless applicant.benefit_type == 'none'
    return partner if partner && partner.benefit_type != 'none'

    applicant
  end

  private

  # involvement_in_case is stored on partner_detail when a database applications and
  # partner when a datastore application.
  def partner_involvement_in_case
    return partner_detail.involvement_in_case if partner_detail

    partner&.involvement_in_case
  end

  # conflict_of_interest is stored on partner_detail when a database applications and
  # partner when a datastore application.
  def partner_conflict_of_interest
    return partner_detail.conflict_of_interest if partner_detail

    partner&.conflict_of_interest
  end

  def has_passporting_benefit?
    BenefitType.passporting.include?(BenefitType.new(benefit_check_recipient.benefit_type.to_s))
  end

  def summary_only?
    kase.case_type == CaseType::SUMMARY_ONLY.to_s
  end

  def committal?
    kase.case_type == CaseType::COMMITTAL.to_s
  end

  def no_property?
    income.client_owns_property == 'no'
  end

  def no_savings?
    income.has_savings == 'no'
  end

  def has_frozen_assets?
    income.has_frozen_income_or_assets == 'yes'
  end

  def income_below_threshold?
    income&.income_above_threshold == 'no'
  end

  def income_above_threshold?
    !income_below_threshold?
  end
end
