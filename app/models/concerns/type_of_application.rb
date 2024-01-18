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
    application_type?(:initial)
  end

  def returned?
    returned_at.present?
  end

  def post_submission_evidence?
    application_type?(:post_submission_evidence)
  end
  alias pse? post_submission_evidence?

  private

  def application_type?(other_type)
    ApplicationType.new(application_type) == ApplicationType.new(other_type)
  end
end
