require 'rails_helper'

RSpec.describe 'Accessibility page' do
  %w[en cy].each do |locale|
    context "in #{locale}" do
      before do
        visit about_accessibility_path(locale:)
      end

      it 'directs both accessibility contacts to the accessibility team' do
        expect(page).to have_link('accessibility@justice.gov.uk',
                                  href: 'mailto:accessibility@justice.gov.uk', count: 2)
        expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
      end
    end
  end
end
