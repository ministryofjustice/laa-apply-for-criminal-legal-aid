require 'rails_helper'

RSpec.describe 'steps/income/partner/deductions/edit', type: :view do
  subject(:render_view) { render template: 'steps/income/partner/deductions/edit' }

  let(:crime_application) { CrimeApplication.new }
  let(:employment) { Employment.create!(crime_application: crime_application, ownership_type: OwnershipType::PARTNER.to_s) }

  let(:form_object) do
    Steps::Income::Partner::DeductionsForm.new(crime_application:).tap do |form|
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

  describe 'error summary accessibility when nothing is selected' do
    it 'links the error summary to an input that exists on the page' do
      render_view

      document = Capybara.string(rendered)
      hrefs = document.all('.govuk-error-summary__list a').pluck(:href)

      expect(hrefs).not_to be_empty
      hrefs.each do |href|
        expect(document).to have_css("##{href.delete_prefix('#')}")
      end
    end

    it 'targets the first deduction checkbox' do
      render_view

      document = Capybara.string(rendered)
      href = document.first('.govuk-error-summary__list a')[:href]
      target = document.find(href)

      expect(target.tag_name).to eq('input')
      expect(target[:type]).to eq('checkbox')
      expect(target[:value]).to eq('income_tax')
    end
  end
end
