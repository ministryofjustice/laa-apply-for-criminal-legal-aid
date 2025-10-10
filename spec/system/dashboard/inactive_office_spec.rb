require 'rails_helper'

RSpec.describe 'Viewing dashboard with an office that becomes inactive' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  before do
    visit('/')
  end

  it 'redirects to the select office page' do
    expect(page).not_to have_content('Select your office account number')
    mock_pda('2A555X', fixture: 'prison_only')

    visit current_path

    expect(page).to have_content('Select your office account number')
  end
end
