require 'rails_helper'

RSpec.describe 'steps/case/ioj/edit', type: :view do
  subject(:render_view) { render template: 'steps/case/ioj/edit' }

  let(:crime_application) { CrimeApplication.new }
  let(:form_object) { Steps::Case::IojForm.build(crime_application) }
  let(:audit_required) { true }

  before do
    view.class.include StepsHelper
    assign(:form_object, form_object)
    allow(view).to receive_messages(
      current_crime_application: crime_application,
      current_form_object: form_object
    )
    allow(crime_application).to receive(:slipstream_audit_ioj_required?).and_return(audit_required)
    allow(controller).to receive(:controller_path).and_return('steps/case/ioj')
    stub_template 'layouts/_step_header.html.erb' => ''

    without_partial_double_verification do
      allow(view).to receive(:step_form) do |record, opts = {}, &block|
        view.form_for(record, { url: '/stub', method: :put }.merge(opts || {}), &block)
      end
    end
  end

  it 'keeps the banner visible when the form is redisplayed with validation errors' do
    form_object.valid?

    render_view

    document = Capybara.string(rendered)
    expect(document).to have_css('.govuk-notification-banner', text: 'Important')
    expect(document).to have_css('.govuk-error-summary')
    expect(document).to have_css('h1', text: 'Why should your client get legal aid?')
  end

  context 'when the audit IoJ requirement does not apply' do
    let(:audit_required) { false }

    it 'does not show the audit banner' do
      render_view

      expect(rendered).not_to include('For assurance purposes')
    end
  end
end
