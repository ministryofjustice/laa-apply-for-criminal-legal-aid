require 'rails_helper'

RSpec.describe 'Custom infrastructure error pages' do # rubocop:disable RSpec/DescribeClass
  %w[production staging].each do |environment|
    context "in #{environment}" do
      subject(:page) do
        config = YAML.load_file(Rails.root.join("config/kubernetes/#{environment}/custom-error-page.yml"))
        Capybara.string(config.fetch('data').fetch('423.html'))
      end

      it 'directs users to the technical fault reporting form in a new tab' do
        expect(page).to have_css('p', text: 'If this is preventing you from using the digital service, you can')
        expect(page).to have_link('submit a technical fault request (opens in a new tab)', exact: true,
                                  href: 'https://laa-technical-fault-reporting-form.form.service.justice.gov.uk/',
                                  target: '_blank')
        expect(page.find_link('submit a technical fault request (opens in a new tab)')[:rel]).to include('noopener')
        expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
      end
    end
  end
end
