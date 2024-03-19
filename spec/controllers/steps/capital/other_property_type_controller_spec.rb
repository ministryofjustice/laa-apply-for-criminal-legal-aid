require 'rails_helper'

RSpec.describe Steps::Capital::OtherPropertyTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::OtherPropertyTypeForm,
                  Decisions::CapitalDecisionTree
end
