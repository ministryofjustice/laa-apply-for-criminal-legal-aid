require 'rails_helper'

RSpec.describe 'Privacy page' do
  [true, false].each do |analytics_enabled|
    context "when Google Analytics is #{analytics_enabled ? 'enabled' : 'disabled'}" do
      before do
        allow(FeatureFlags).to receive(:google_analytics).and_return(
          instance_double(FeatureFlags::EnabledFeature, enabled?: analytics_enabled)
        )

        visit about_privacy_path
      end

      it 'uses the confirmed data protection contact address and complaints link' do
        expect(page).to have_css('p', text: 'Email dataprotection@justice.gov.uk if you:')
        expect(page).to have_link('dataprotection@justice.gov.uk',
                                  href: 'mailto:dataprotection@justice.gov.uk', count: 2)
        expect(page).to have_css('p', text: 'Or you can complain to the Legal Aid Agency.')
        expect(page).to have_link('complain to the Legal Aid Agency',
                                  href: 'https://complain-to-the-laa.form.service.justice.gov.uk/')
        expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
        expect(page).not_to have_link(href: 'mailto:accessibility@justice.gov.uk')
      end

      it 'preserves the existing reasons for contacting us and the DPO details' do
        expect(page).to have_css('li', text: 'have a question about anything in this privacy notice')
        expect(page).to have_css('li', text: 'think that your personal data has been misused or mishandled')
        expect(page).to have_link('dataprotection@justice.gov.uk', href: 'mailto:dataprotection@justice.gov.uk')
      end

      it 'updates the notice revision date' do
        expect(page).to have_text('Last updated 26 October 2026')
      end

      it 'uses the supplied official Welsh email and complaints copy' do
        visit about_privacy_path(locale: 'cy')

        expect(page).to have_css('p', text: 'Anfonnwch e-bost at dataprotection@justice.gov.uk os:')
        expect(page).to have_css('p', text: "Neu gallwch gwyno i'r Asiantaeth Cymorth Cyfreithiol.")
        expect(page).to have_link("gwyno i'r Asiantaeth Cymorth Cyfreithiol", exact: true,
                                  href: 'https://complain-to-the-laa.form.service.justice.gov.uk/')
        expect(page).to have_link('dataprotection@justice.gov.uk',
                                  href: 'mailto:dataprotection@justice.gov.uk', count: 2)
        expect(page).not_to have_link(href: 'mailto:online-support@justice.gov.uk')
        expect(page).not_to have_link(href: 'mailto:accessibility@justice.gov.uk')
      end
    end
  end
end
