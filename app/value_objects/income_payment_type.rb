class IncomePaymentType < ValueObject
  VALUES = [
    LOSS = new(:loss_of_liberty),
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
end
