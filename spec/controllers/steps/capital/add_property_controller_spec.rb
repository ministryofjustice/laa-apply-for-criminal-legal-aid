require 'rails_helper'

RSpec.describe Steps::Capital::AddPropertyController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::AddPropertyForm,
                  Decisions::CapitalDecisionTree
end
