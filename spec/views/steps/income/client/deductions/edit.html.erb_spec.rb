require 'rails_helper'

RSpec.describe 'steps/income/client/deductions/edit', type: :view do
  subject(:render_view) { render template: 'steps/income/client/deductions/edit' }

  let(:crime_application) { CrimeApplication.new }
  let(:employment) { Employment.create!(crime_application:) }

  let(:form_object) do
    Steps::Income::Client::DeductionsForm.new(
      crime_application: crime_application,
      types: []
    ).tap do |form|
      form.employment = employment
    end
  end

  before do
    view.class.include StepsHelper
    assign(:form_object, form_object)
    allow(view).to receive_messages(
      current_crime_application: crime_application,
      current_form_object: form_object
    )
    without_partial_double_verification do
      allow(controller).to receive_messages(
        controller_path: 'steps/income/client/deductions',
        current_form_object: form_object
      )
    end
    stub_template 'layouts/_step_header.html.erb' => ''

    without_partial_double_verification do
      allow(view).to receive(:step_form) do |record, opts = {}, &block|
        view.form_for(record, { url: '/stub', method: :put }.merge(opts || {}), &block)
      end
    end

    form_object.valid?
  end

  it 'renders the validation error inline on the deductions fieldset' do
    render_view

    expect(rendered).to have_css(
      '.govuk-form-group--error .govuk-error-message',
      text: 'Select and enter a deduction or select that your client does not have deductions taken from their pay'
    )
  end

  describe 'error summary accessibility when nothing is selected' do
    it 'links the error summary to an element that exists on the page' do
      render_view

      document = Capybara.string(rendered)
      hrefs = document.all('.govuk-error-summary__list a').pluck(:href)

      expect(hrefs).not_to be_empty
      hrefs.each do |href|
        expect(document).to have_css("##{href.delete_prefix('#')}")
      end
    end
  end
end
