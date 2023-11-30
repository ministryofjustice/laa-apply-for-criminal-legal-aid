require 'rails_helper'

RSpec.describe Steps::Income::ClientHaveDependantsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::ClientHaveDependantsForm, Decisions::IncomeDecisionTree
end
