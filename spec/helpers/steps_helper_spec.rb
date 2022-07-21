require 'rails_helper'

RSpec.describe StepsHelper, type: :helper do
  describe '#step_form' do
    let(:foo_bar_record) {
      Class.new(ApplicationRecord) do
        def self.load_schema!; @columns_hash = {}; end
      end
    }

    before do
      stub_const('FooBarRecord', foo_bar_record)
    end

    let(:expected_defaults) { {
      url: {
        controller: 'steps',
        action: :update
      },
      html: {
        class: 'edit_foo_bar_record'
      },
      method: :put
    } }

    let(:form_block) { Proc.new {} }
    let(:record) { foo_bar_record.new }

    it 'acts like FormHelper#form_for with additional defaults' do
      expect(helper).to receive(:form_for).with(record, expected_defaults) do |*_args, &block|
        expect(block).to eq(form_block)
      end
      helper.step_form(record, &form_block)
    end

    it 'accepts additional options like FormHelper#form_for would' do
      expect(helper).to receive(:form_for).with(record, expected_defaults.merge(foo: 'bar'))
      helper.step_form(record, { foo: 'bar' })
    end

    it 'appends optional css classes if provided' do
      expect(helper).to receive(:form_for).with(record, expected_defaults.merge(html: {class: %w(test edit_foo_bar_record)}))
      helper.step_form(record, html: { class: 'test' })
    end
  end

  describe '#step_header' do
    let(:current_crime_application) { instance_double(CrimeApplication, navigation_stack: navigation_stack) }
    let(:navigation_stack) { %w(/step1 /step2 /step3) }

    before do
      allow(view).to receive(:current_crime_application).and_return(current_crime_application)
    end

    context 'there is a previous path in the stack' do
      it 'renders the back link to the previous path' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(/<a class="govuk-back-link" href="\/step2">Back<\/a>/)
      end
    end

    context 'there is no previous path in the stack' do
      let(:navigation_stack) { nil }

      it 'renders the back link to the root path as fallback' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(/<a class="govuk-back-link" href="\/">Back<\/a>/)
      end
    end

    context 'a specific path is provided' do
      it 'renders the back link with the provided path' do
        helper.step_header(path: '/another/step')
        expect(view.content_for(:back_link)).to match(/<a class="govuk-back-link" href="\/another\/step">Back<\/a>/)
      end
    end
  end

  describe '#govuk_error_summary' do
    context 'when no form object is given' do
      let(:form_object) { nil }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object without errors is given' do
      let(:form_object) { Steps::BaseFormObject.new }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object with errors is given' do
      let(:form_object) { Steps::BaseFormObject.new }
      let(:title) { helper.content_for(:page_title) }

      before do
        helper.title('A page')
        form_object.errors.add(:base, :blank)
      end

      it 'returns the summary' do
        expect(
          helper.govuk_error_summary(form_object)
        ).to eq(
          '<div class="govuk-error-summary" role="alert" data-module="govuk-error-summary" aria-labelledby="error-summary-title"><h2 id="error-summary-title" class="govuk-error-summary__title">There is a problem on this page</h2><div class="govuk-error-summary__body"><ul class="govuk-list govuk-error-summary__list"><li><a data-turbo="false" href="#steps-base-form-object-base-field-error">can&#39;t be blank</a></li></ul></div></div>'
        )
      end

      it 'prepends the page title with an error hint' do
        helper.govuk_error_summary(form_object)
        expect(title).to start_with('Error: A page')
      end
    end
  end

  describe '#link_button' do
    it 'builds the link markup styled as a button' do
      expect(
        helper.link_button('Continue', root_path)
      ).to eq('<a class="govuk-button" role="button" draggable="false" data-module="govuk-button" href="/">Continue</a>')
    end

    it 'appends to the default attributes where possible, otherwise overwrite them' do
      expect(
        helper.link_button('Continue', root_path, class: 'ga-pageLink', draggable: true, data: { module: 'govuk-button', ga_category: 'category', ga_label: 'label' })
      ).to eq('<a class="govuk-button ga-pageLink" role="button" draggable="true" data-module="govuk-button" data-ga-category="category" data-ga-label="label" href="/">Continue</a>')
    end
  end
end
