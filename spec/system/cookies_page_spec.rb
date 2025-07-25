require 'rails_helper'

RSpec.describe 'Cookies page' do
  before do
    visit cookies_path
  end

  it 'references the crime apply session cookied' do
    expect(page).to have_text(Rails.application.config.session_options[:key])
  end
end
