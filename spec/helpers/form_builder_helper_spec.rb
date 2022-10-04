require 'rails_helper'

RSpec.describe FormBuilderHelper, type: :helper do
  let(:form_object) { double('FormObject') }

  let(:builder) do
    GOVUKDesignSystemFormBuilder::FormBuilder.new(
      :object_name,
      form_object,
      self,
      {}
    )
  end

  describe '#continue_button' do
    context 'when there is no secondary action' do
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true">Save and continue</button>'
      end

      it 'outputs only the continue button' do
        expect(
          builder.continue_button(secondary: false)
        ).to eq(expected_markup)
      end
    end

    context 'when there is a secondary action' do
      let(:expected_markup) do
        '<div class="govuk-button-group">' \
          '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true">Save and continue</button>' \
          '<button type="submit" formnovalidate="formnovalidate" class="govuk-button govuk-button--secondary" ' \
          'data-module="govuk-button" data-prevent-double-click="true" name="commit_draft">' \
          'Save and come back later</button></div>'
      end

      it 'outputs the continue button together with a save draft button' do
        expect(
          builder.continue_button
        ).to eq(expected_markup)
      end
    end

    context 'button text can be customised' do
      before do
        # Ensure we don't rely on specific locales, so we have predictable tests
        allow(I18n).to receive(:t).with('helpers.submit.find_address').and_return('Find address')
        allow(I18n).to receive(:t).with('helpers.submit.enter_manually').and_return('Enter address manually')
      end

      it 'outputs the buttons with specific text' do
        html = builder.continue_button(primary: :find_address, secondary: :enter_manually)
        doc = Nokogiri::HTML.fragment(html)

        assert_select(doc, 'button', attributes: { name: nil }, text: 'Find address')
        assert_select(doc, 'button', attributes: { name: 'commit_draft' }, text: 'Enter address manually')
      end
    end
  end
end
