require 'rails_helper'

describe Summary::Sections::Investments do
  it_behaves_like 'a capital records section' do
    let(:capital) { instance_double(Capital, has_no_investments: has_no_answer, investments: records,) }
    let(:record) { Investment.new }
    let(:expected_question_text) { 'Investments?' }
    let(:expected_change_path) { 'applications/12345/steps/capital/which-investments' }
  end
end
