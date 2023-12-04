require 'rails_helper'

RSpec.describe Steps::Income::HasSavingsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::HasSavingsForm,
                  Decisions::IncomeDecisionTree
end
