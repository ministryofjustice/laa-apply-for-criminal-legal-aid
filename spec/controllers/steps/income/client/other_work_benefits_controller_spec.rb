require 'rails_helper'

RSpec.describe Steps::Income::Client::OtherWorkBenefitsController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Client::OtherWorkBenefitsForm, Decisions::IncomeDecisionTree
end
