require 'rails_helper'

RSpec.describe Steps::Capital::AnswersController, type: :controller do
  let(:has_no_other_assets) { has_no_other_assets }

  it_behaves_like(
    'a generic step controller',
    Steps::Capital::AnswersForm,
    Decisions::CapitalDecisionTree
  )
end
