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
    ApplicationType.new(application_type) == ApplicationType::INITIAL
  end

  def returned?
    returned_at.present?
  end
end
