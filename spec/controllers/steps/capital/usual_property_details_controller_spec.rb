require 'rails_helper'

RSpec.describe Steps::Capital::UsualPropertyDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::UsualPropertyDetailsForm,
                  Decisions::CapitalDecisionTree
end
