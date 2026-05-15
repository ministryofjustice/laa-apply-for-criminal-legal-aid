require 'rails_helper'

RSpec.describe Summary::Components::EnTextAnswer do
  subject(:component) { described_class.new(:en_text_answer, text) }

  describe '#answer_text' do
    context 'when supplied with text' do
      let(:text) { 'Leeds Crown Court' }

      it 'renders the supplied text' do
        result = component.answer_text
        expect(result).to include('Leeds Crown Court')
      end

      it 'wrapped in an element with lang attribute set to English' do
        result = component.answer_text
        expect(result).to include('lang="en"')
      end

      it 'wrapped in an element with class of govuk-body' do
        result = component.answer_text
        expect(result).to include('class="govuk-body"')
      end
    end
  end
end
