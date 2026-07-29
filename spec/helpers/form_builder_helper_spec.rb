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
    # rubocop:disable Layout/LineLength
    context 'when there is no secondary action' do
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true" data-main-action="true">Save and continue</button>'
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
          'data-module="govuk-button" data-prevent-double-click="true" data-main-action="true">Save and continue</button>' \
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
    # rubocop:enable Layout/LineLength

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

    context 'custom attributes' do
      it 'outputs the buttons with additional attributes' do
        html = builder.continue_button(
          primary_opts: { class: 'custom-class-primary', foo: 'bar' },
          secondary_opts: { class: 'custom-class-secondary' }
        )
        doc = Nokogiri::HTML.fragment(html)

        assert_select(
          doc, 'button', attributes: { class: 'govuk-button custom-class-primary', foo: 'bar' }
        )
        assert_select(
          doc, 'button', attributes: { class: 'govuk-button govuk-button--secondary custom-class-secondary' }
        )
      end
    end
  end

  describe '#govuk_number_field' do
    before do
      allow(form_object).to receive_messages(amount: nil, errors: ActiveModel::Errors.new(form_object))
    end

    context 'when prefix_text is £' do
      it 'includes a visually hidden "Amount in pounds" span in the label' do
        html = builder.govuk_number_field(:amount, prefix_text: '£', label: { text: 'Enter amount' })
        doc = Nokogiri::HTML.fragment(html)

        label = doc.at_css('label')
        expect(label).to be_present
        expect(label.text).to include('Enter amount')

        hidden_span = label.at_css('span.govuk-visually-hidden')
        expect(hidden_span).to be_present
        expect(hidden_span.text.strip).to eq('Amount in pounds')
      end

      it 'preserves the real translated label text alongside the currency hint' do
        # Uses a genuine application form object and its real translation key to
        # confirm that label text resolution and currency hint injection both work
        # correctly end-to-end, without relying on mocked I18n lookups.
        savings_form = Steps::Capital::SavingsForm.new(nil)
        real_builder = GOVUKDesignSystemFormBuilder::FormBuilder.new(
          :steps_capital_savings_form, savings_form, self, {}
        )

        html = real_builder.govuk_number_field(:account_balance, prefix_text: '£', label: { tag: 'h2', size: 'm' })
        doc = Nokogiri::HTML.fragment(html)

        label = doc.at_css('label')
        expect(label.text).to include('What is the account balance?')

        hidden_span = label.at_css('span.govuk-visually-hidden')
        expect(hidden_span).to be_present
        expect(hidden_span.text.strip).to eq('Amount in pounds')
      end

      it 'renders the £ prefix symbol with aria-hidden on the input wrapper' do
        html = builder.govuk_number_field(:amount, prefix_text: '£', label: { text: 'Enter amount' })
        doc = Nokogiri::HTML.fragment(html)

        prefix = doc.at_css('span.govuk-input__prefix')
        expect(prefix).to be_present
        expect(prefix['aria-hidden']).to eq('true')
      end
    end

    context 'when prefix_text is not £' do
      it 'does not inject a visually hidden span into the label' do
        html = builder.govuk_number_field(:amount, prefix_text: 'kg', label: { text: 'Enter weight' })
        doc = Nokogiri::HTML.fragment(html)

        label = doc.at_css('label')
        expect(label.at_css('span.govuk-visually-hidden')).to be_nil
      end
    end

    context 'when prefix_text is not set' do
      it 'does not inject a visually hidden span into the label' do
        html = builder.govuk_number_field(:amount, label: { text: 'Enter amount' })
        doc = Nokogiri::HTML.fragment(html)

        label = doc.at_css('label')
        expect(label.at_css('span.govuk-visually-hidden')).to be_nil
      end
    end
  end
end
