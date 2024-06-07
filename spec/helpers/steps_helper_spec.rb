require 'rails_helper'

RSpec.describe StepsHelper, type: :helper do
  describe '#step_form' do
    let(:foo_bar_record) do
      Class.new(ApplicationRecord) do
        def self.load_schema! = @columns_hash = {}
      end
    end
    let(:expected_defaults) do
      {
        url: {
          controller: 'steps',
          action: :update
        },
      html: {
        class: 'edit_foo_bar_record'
      },
      method: :put
      }
    end
    let(:form_block) { proc {} }
    let(:record) { foo_bar_record.new }

    before do
      stub_const('FooBarRecord', foo_bar_record)
    end

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
      expect(helper).to receive(:form_for).with(record,
                                                expected_defaults.merge(html: { class: %w[test edit_foo_bar_record] }))
      helper.step_form(record, html: { class: 'test' })
    end
  end

  describe '#step_header' do
    let(:current_crime_application) { instance_double(CrimeApplication, navigation_stack:) }
    let(:navigation_stack) { %w[/step1 /step2 /step3] }

    before do
      allow(view).to receive(:current_crime_application).and_return(current_crime_application)
    end

    context 'there is a previous path in the stack' do
      it 'renders the back link to the previous path' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/step2">Back</a>})
      end
    end

    context 'there is no previous path in the stack' do
      let(:navigation_stack) { nil }

      it 'renders the back link to the root path as fallback' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/">Back</a>})
      end
    end

    context 'a specific path is provided' do
      it 'renders the back link with the provided path' do
        helper.step_header(path: '/another/step')
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/another/step">Back</a>})
      end
    end
  end

  describe '#previous_step_path' do
    let(:current_crime_application) { instance_double(CrimeApplication, navigation_stack:) }

    before do
      allow(view).to receive(:current_crime_application).and_return(current_crime_application)
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'returns the root path' do
        expect(helper.previous_step_path).to eq('/')
      end
    end

    context 'when the stack has elements' do
      let(:navigation_stack) { %w[/somewhere /over /the /rainbow] }

      it 'returns the element before the last page' do
        expect(helper.previous_step_path).to eq('/the')
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
          '<div class="govuk-error-summary" data-module="govuk-error-summary">' \
          '<div role="alert"><h2 class="govuk-error-summary__title">There is a problem on this page</h2>' \
          '<div class="govuk-error-summary__body"><ul class="govuk-list govuk-error-summary__list">' \
          '<li><a data-turbo="false" href="#steps-base-form-object-base-field-error">can&#39;t be blank</a></li>' \
          '</ul></div></div></div>'
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
      ).to eq(
        '<a class="govuk-button" role="button" draggable="false" data-module="govuk-button" href="/">Continue</a>'
      )
    end

    it 'appends to the default attributes where possible, otherwise overwrite them' do
      expect(
        helper.link_button('Continue', root_path, class: 'ga-pageLink', draggable: true,
data: { module: 'govuk-button', ga_category: 'category', ga_label: 'label' })
      ).to eq(
        '<a class="govuk-button ga-pageLink" role="button" draggable="true" data-module="govuk-button" ' \
        'data-ga-category="category" data-ga-label="label" href="/">Continue</a>'
      )
    end

    it 'supports block for content' do
      expect(
        helper.link_button(nil, root_path, draggable: true) { 'Drag this' }
      ).to eq(
        '<a class="govuk-button" role="button" draggable="true" data-module="govuk-button" href="/">Drag this</a>'
      )
    end
  end

  describe '#hint_t' do
    it 'sources hint translations from the same source as the GOV.UK Form Builder' do
      allow(view).to receive(:current_form_object) { Steps::BaseFormObject.new }
      expect(helper).to receive(:t).with(
        :attribute, scope: 'helpers.hint.steps_base_form_object'
      )

      helper.hint_t(:attribute)
    end
  end

  describe '#label_t' do
    it 'sources label translations from the same source as the GOV.UK Form Builder' do
      allow(view).to receive(:current_form_object) { Steps::BaseFormObject.new }
      expect(helper).to receive(:t).with(
        :attribute, scope: 'helpers.label.steps_base_form_object'
      )

      helper.label_t(:attribute)
    end
  end

  describe '#legend_t' do
    it 'sources label translations from the same source as the GOV.UK Form Builder' do
      allow(view).to receive(:current_form_object) { Steps::BaseFormObject.new }
      expect(helper).to receive(:t).with(
        :attribute, scope: 'helpers.label.steps_base_form_object'
      )

      helper.label_t(:attribute)
    end

    # We've included a concrete example here in lieu of an
    # integration spec to illustrate the use of the I18n helper.
    #
    # TODO: consider integration specs for the dynamic subject form content.
    #
    context 'when subject could be plural, e.g. ApplicantAndPartner' do
      before do
        form_object = Steps::Income::ManageWithoutIncomeForm.new
        allow(view).to receive(:current_form_object) { form_object }
        allow(form_object).to receive(:include_partner_in_means_assessment?) { include_partner? }
      end

      context 'when subject is applicant AND partner' do
        let(:include_partner?) { true }

        it 'returns the pluralized translation' do
          expect(helper.legend_t(:manage_without_income)).to eq(
            'How do your client and their partner manage with no income?'
          )
        end
      end

      context 'when subject is applicant only' do
        let(:include_partner?) { false }

        it 'returns the singular translation' do
          expect(helper.legend_t(:manage_without_income)).to eq(
            'How does your client manage with no income?'
          )
        end
      end
    end
  end

  describe '#translate_with_subject' do
    before do
      form_object = double(
        :mock_form_object,
        model_name: Steps::BaseFormObject,
        form_subject: form_subject
      )

      allow(view).to receive(:current_form_object).and_return(form_object)
    end

    let(:form_subject) { nil }

    it 'injects "subject", capitalized subject ("Subject") and "count" into the I18n options' do
      expect(helper).to receive(:translate).with(
        :translation_key,
        { Subject: 'The subject', count: 1, subject: 'the subject' }
      )

      helper.translate_with_subject(:translation_key, subject: 'the subject')
    end

    context 'when form subject is ApplicantAndPartner' do
      let(:form_subject) { SubjectType::APPLICANT_AND_PARTNER }

      it 'sets the count to 2' do
        expect(helper).to receive(:translate).with(:translation_key, hash_including(count: 2))

        helper.translate_with_subject(:translation_key, subject: 'the subject')
      end
    end
  end
end
