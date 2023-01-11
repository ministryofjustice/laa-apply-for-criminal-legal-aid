class ChargePresenter < BasePresenter
  delegate :offence_class, :offence_type,
           to: :offence, allow_nil: true

  def offence
    OffencePresenter.present(super) if super
  end

  def offence_dates
    return [] unless valid_dates?

    super.pluck(:date_from, :date_to)
  end
end
