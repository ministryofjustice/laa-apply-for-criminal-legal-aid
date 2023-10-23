require 'rails_helper'

RSpec.describe Decisions::IncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'
end
