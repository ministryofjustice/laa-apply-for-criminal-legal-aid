require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingsMoreThanIncomeController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller', Steps::Outgoings::OutgoingsMoreThanIncomeForm,
                  Decisions::OutgoingsDecisionTree
end
