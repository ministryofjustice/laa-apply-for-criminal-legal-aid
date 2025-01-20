require 'rails_helper'

describe Summary::Sections::Savings do
  it_behaves_like 'a capital records section' do
    let(:capital) do
      instance_double(Capital, has_no_savings: has_no_answer, savings: records)
    end

    let(:record) { Saving.new }
    let(:expected_question_text) { 'Savings?' }
    let(:expected_change_path) { 'applications/12345/steps/capital/which-savings' }
  end
end
