class ChargePresenter < BasePresenter
  # TODO: some methods produce mock data for now

  def offence_name
    super || id
  end

  def offence_class
    'H'
  end

  def offence_dates
    super.pluck(:date).compact
  end
end
