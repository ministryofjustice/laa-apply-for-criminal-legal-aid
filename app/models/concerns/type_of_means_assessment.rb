module TypeOfMeansAssessment # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  delegate :applicant, :partner, :kase, :income, :outgoings, :income_payments, :income_benefits,
           :capital, :non_means_tested?, :appeal_no_changes?, :partner_detail, to: :crime_application, allow_nil: true

  def requires_means_assessment?
    return false if Passporting::MeansPassporter.new(crime_application).call
    return false if appeal_no_changes?

    !evidence_of_passporting_means_forthcoming?
  end

  def requires_full_means_assessment? # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    return false unless requires_means_assessment?
    return true if income_above_threshold? || has_frozen_assets?
    return true if client_or_means_assessed_partner_self_employed?

    raise Errors::CannotYetDetermineFullMeans unless income_below_threshold? && has_no_frozen_assets?

    return false if summary_only? || committal?
    return true if has_property? || has_savings?
    return false if no_property? && no_savings?

    raise Errors::CannotYetDetermineFullMeans
  end

  def extent_of_means_assessment_determined?
    requires_full_means_assessment? || true
  rescue Errors::CannotYetDetermineFullMeans
    false
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
    return false if non_means_tested?
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
    return false unless benefit_check_subject.has_nino == 'no'
    return false if benefit_check_subject.will_enter_nino == 'yes'

    benefit_check_subject.will_enter_nino == 'no' || kase.is_client_remanded == 'yes'
  end

  def benefit_evidence_forthcoming?
    return false unless has_passporting_benefit?
    return false if benefit_check_subject.nino.blank?

    benefit_check_subject.has_benefit_evidence == 'yes'
  end

  def means_assessment_as_benefit_evidence?
    return false unless has_passporting_benefit?
    return false if benefit_check_subject.nino.blank?

    benefit_check_subject.has_benefit_evidence == 'no'
  end

  def benefit_check_subject
    return applicant unless include_partner_in_means_assessment?
    return applicant unless benefit_check_not_required(applicant)
    return partner if partner && !benefit_check_not_required(partner)

    applicant
  end

  def insufficient_income_declared?
    !(income&.all_income_over_zero? || income&.client_self_employed? || income&.partner_self_employed?)
  end

  private

  alias not_means_tested? non_means_tested?

  def benefit_check_not_required(person)
    person&.benefit_type == 'none' || person&.arc.present?
  end

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
    BenefitType.passporting.include?(BenefitType.new(benefit_check_subject.benefit_type.to_s))
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

  def has_property?
    income.client_owns_property == 'yes'
  end

  def has_savings?
    income.has_savings == 'yes'
  end

  def no_savings?
    income.has_savings == 'no'
  end

  def has_frozen_assets?
    income&.has_frozen_income_or_assets == 'yes'
  end

  def has_no_frozen_assets?
    income&.has_frozen_income_or_assets == 'no'
  end

  def income_below_threshold?
    income&.income_above_threshold == 'no'
  end

  def income_above_threshold?
    income&.income_above_threshold == 'yes'
  end

  def client_or_means_assessed_partner_self_employed?
    return false if income.blank?
    return true if income.client_self_employed?
    return false unless include_partner_in_means_assessment?

    income.partner_self_employed?
  end
end
