require 'rails_helper'

RSpec.describe Steps::Income::AnswersController, type: :controller do
  it_behaves_like(
    'a generic step controller',
    Steps::Income::AnswersForm,
    Decisions::IncomeDecisionTree
  )
end
