require 'rails_helper'

RSpec.describe Steps::Capital::AnswersController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::AnswersForm,
                  Decisions::CapitalDecisionTree
end
