require 'rails_helper'

RSpec.describe Steps::Income::ClientHasDependantsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::ClientHasDependantsForm, Decisions::IncomeDecisionTree
end
