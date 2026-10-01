require 'rails_helper'

RSpec.describe 'shared/slipstream_audit_notice', type: :view do
  subject(:render_notice) { render partial: 'shared/slipstream_audit_notice' }

  let(:crime_application) { instance_double(CrimeApplication, slipstream_audit_ioj_required?: required) }
  let(:required) { true }

  before do
    allow(view).to receive(:current_crime_application).and_return(crime_application)
  end

  it 'shows the assurance notice when the audit IoJ requirement applies' do
    render_notice

    expect(rendered).to include('Important')
    expect(rendered).to include(
      'For assurance purposes, Interests of Justice (IOJ) reasons are required for this application.'
    )
  end
end
