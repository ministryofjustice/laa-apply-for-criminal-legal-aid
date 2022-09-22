class ChargePresenter < BasePresenter
  delegate :offence_class, :offence_type,
           to: :offence, allow_nil: true

  def offence
    OffencePresenter.present(super) if super
  end

  def offence_dates
    super.pluck(:date).compact
  end
end
