class IncomePresenter < BasePresenter
  def employment_status_text
    employment_status.join('_and_')
  end

  def partner_employment_status_text
    partner_employment_status.join('_and_')
  end
end
