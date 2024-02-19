require 'rails_helper'

RSpec.describe Steps::Capital::SavingsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::SavingTypeForm,
                  Decisions::CapitalDecisionTree
end
