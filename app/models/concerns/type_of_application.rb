module TypeOfApplication
  extend ActiveSupport::Concern

  def reviewed?
    reviewed_at.present?
  end

  def can_receive_pse?
    return false if returned?
    return false unless initial?

    reviewed?
  end

  def funding_decision_missing?
    return false unless decided?
    return false if pse?

    decisions.empty?
  end

  def initial?
    application_type_eql?(:initial)
  end

  def returned?
    returned_at.present?
  end

  def decided?
    review_status == Types::ReviewApplicationStatus['assessment_completed']
  end

  def resubmission?
    initial? && parent_id.present?
  end

  def post_submission_evidence?
    application_type_eql?(:post_submission_evidence)
  end
  alias pse? post_submission_evidence?

  def change_in_financial_circumstances?
    application_type_eql?(:change_in_financial_circumstances)
  end
  alias cifc? change_in_financial_circumstances?

  def appeal_no_changes?
    return false unless kase.present? && kase.appeal_original_app_submitted == 'yes'

    kase.case_type == CaseType::APPEAL_TO_CROWN_COURT.to_s &&
      kase.appeal_financial_circumstances_changed == 'no'
  end

  def non_means_tested?
    return false if change_in_financial_circumstances?

    is_means_tested == 'no'
  end

  private

  def application_type_eql?(other_type)
    ApplicationType.new(application_type) == ApplicationType.new(other_type)
  end
end
