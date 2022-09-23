class OffencePresenter < BasePresenter
  def offence_class
    t('steps.shared.offence_class', class: class_to_sentence(super))
  end

  private

  def class_to_sentence(letters)
    letters.split('/').to_sentence(
      two_words_connector: t('shared.or_sentence.two_words_connector'),
      last_word_connector: t('shared.or_sentence.last_word_connector')
    )
  end
end
