class SavingPresenter < BasePresenter
  def format_saving_type
    t("steps.shared.saving.#{saving_type}")
  end

  def format_sort_code
    sort_code
  end
end
