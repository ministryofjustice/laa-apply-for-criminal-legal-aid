require 'rails_helper'

RSpec.describe Steps::Capital::OtherSavingTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::OtherSavingTypeForm,
                  Decisions::CapitalDecisionTree
end
