require 'rails_helper'

describe Summary::Components::TagAnswer do
  subject(:component) { described_class.new(question, value) }

  let(:question) { :question }
  let(:value) { :answer }

  before do
    allow(I18n).to receive(:t).with('summary.questions.question.answers.answer').and_return({ value: 'Answer',
colour: 'green' })
  end

  describe '#answer_text' do
    it 'returns a tag with the correct answer and colour' do
      expect(component.answer_text).to eq('<strong class="govuk-tag govuk-tag--green">Answer</strong>')
    end
  end
end
