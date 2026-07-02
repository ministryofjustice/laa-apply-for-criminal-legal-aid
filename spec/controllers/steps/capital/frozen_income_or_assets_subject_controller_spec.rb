require 'rails_helper'

RSpec.describe Steps::Capital::FrozenIncomeOrAssetsSubjectController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Capital::FrozenIncomeOrAssetsSubjectForm,
                  Decisions::CapitalDecisionTree
end
