class OffencePresenter < BasePresenter
  def offence_class
    t('steps.shared.offence_class', class: super)
  end
end
