class ChargePresenter < BasePresenter
  delegate :code,
           to: :offence, allow_nil: true, prefix: true

  delegate :offence_class, :offence_type,
           to: :offence, allow_nil: true, prefix: false

  def offence_dates
    super.pluck(:date).compact
  end
end
