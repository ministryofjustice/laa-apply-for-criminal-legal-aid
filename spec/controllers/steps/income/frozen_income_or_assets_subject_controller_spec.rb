require 'rails_helper'

RSpec.describe Steps::Income::FrozenIncomeOrAssetsSubjectController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::FrozenIncomeOrAssetsSubjectForm,
                  Decisions::IncomeDecisionTree
end
