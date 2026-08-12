require 'rails_helper'

RSpec.describe 'steps/income/partner/deductions/edit', type: :view do
  subject(:render_view) { render template: 'steps/income/partner/deductions/edit' }

  let(:crime_application) { CrimeApplication.new }

  let(:employment) do
    Employment.create!(
      crime_application: crime_application,
      ownership_type: OwnershipType::PARTNER.to_s
    )
  end

  let(:form_object) do
    Steps::Income::Partner::DeductionsForm.new(
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
        controller_path: 'steps/income/partner/deductions',
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
      text: 'Select and enter a deduction or select that the partner does not have deductions taken from their pay'
    )
  end

  describe 'error summary accessibility when nothing is selected' do
    it 'links the error summary to the deductions anchor' do
      render_view

      page = Capybara.string(rendered)
      href = page.find('.govuk-error-summary a')[:href]

      expect(href).to eq('#steps-income-partner-deductions-form-deductions-field-error')
      expect(page).to have_css(href)
    end
  end
end
