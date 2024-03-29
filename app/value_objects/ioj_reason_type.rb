class IojReasonType < ValueObject
  VALUES = [
    LOSS_OF_LIBERTY = new(:loss_of_liberty),
    SUSPENDED_SENTENCE = new(:suspended_sentence),
    LOSS_OF_LIVELIHOOD = new(:loss_of_livelihood),
    REPUTATION = new(:reputation),
    QUESTION_OF_LAW = new(:question_of_law),
    UNDERSTANDING = new(:understanding),
    WITNESS_TRACING = new(:witness_tracing),
    EXPERT_EXAMINATION = new(:expert_examination),
    INTEREST_OF_ANOTHER = new(:interest_of_another),
    OTHER = new(:other)
  ].freeze

  def self.justification_attrs
    values.map(&:justification_field_name)
  end

  def justification_field_name
    [to_s, :justification].join('_').to_sym
  end
end
