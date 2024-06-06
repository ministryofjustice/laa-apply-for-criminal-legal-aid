class OffencePresenter < BasePresenter
  def offence_class
    I18n.t('steps.shared.offence_class', class: super)
  end

  def synonyms
    OffenceSynonyms.lookup(name).join('|').presence
  end
end
