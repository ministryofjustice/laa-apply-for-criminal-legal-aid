require 'rails_helper'

RSpec.describe Steps::Capital::AddSavingController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::AddSavingForm,
                  Decisions::CapitalDecisionTree
end
