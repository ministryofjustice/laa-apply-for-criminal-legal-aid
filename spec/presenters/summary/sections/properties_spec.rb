require 'rails_helper'

describe Summary::Sections::Properties do
  it_behaves_like 'a capital records section' do
    let(:capital) do
      instance_double(
        Capital,
        has_no_properties: has_no_answer,
        properties: records
      )
    end

    let(:record) { Property.new }
    let(:expected_question_text) { 'Assets client owns' }
    let(:expected_no_records_answer) { 'None' }
    let(:expected_no_records_answer_value) { 'none' }
    let(:expected_change_path) { 'applications/12345/steps/capital/which-assets-owned' }
  end
end
