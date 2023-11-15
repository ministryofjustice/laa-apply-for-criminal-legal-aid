require 'rails_helper'

RSpec.describe Steps::Income::ClientOwnsPropertyController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::ClientOwnsPropertyForm, Decisions::IncomeDecisionTree
end
