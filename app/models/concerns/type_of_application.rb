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

  def initial?
    application_type_eql?(:initial)
  end

  def returned?
    returned_at.present?
  end

  def resubmission?
    initial? && parent_id.present?
  end

  def post_submission_evidence?
    application_type_eql?(:post_submission_evidence)
  end
  alias pse? post_submission_evidence?

  private

  def application_type_eql?(other_type)
    ApplicationType.new(application_type) == ApplicationType.new(other_type)
  end
end
