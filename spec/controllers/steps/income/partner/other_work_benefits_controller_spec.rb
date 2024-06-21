require 'rails_helper'

RSpec.describe Steps::Income::Partner::OtherWorkBenefitsController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Partner::OtherWorkBenefitsForm, Decisions::IncomeDecisionTree
end
