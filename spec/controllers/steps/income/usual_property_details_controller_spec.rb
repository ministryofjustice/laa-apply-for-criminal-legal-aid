require 'rails_helper'

RSpec.describe Steps::Income::UsualPropertyDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::UsualPropertyDetailsForm,
                  Decisions::IncomeDecisionTree
end
