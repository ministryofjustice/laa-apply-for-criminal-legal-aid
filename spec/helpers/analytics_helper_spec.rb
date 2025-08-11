require 'rails_helper'

RSpec.describe AnalyticsHelper, type: :helper do
  before do
    allow(
      Rails.configuration.x.analytics
    ).to receive(:ga_tracking_id).and_return(ga_tracking_id)
  end

  let(:ga_tracking_id) { 'XYZ-123' }

  describe '#analytics_tracking_id' do
    it 'retrieves the configuration variable' do
      expect(helper.analytics_tracking_id).to eq('XYZ-123')
    end
  end

  describe '#analytics_consent_cookie' do
    it 'retrieves the analytics consent cookie' do
      expect(controller.cookies).to receive(:[]).with('crime_apply_cookies_consent')
      helper.analytics_consent_cookie
    end
  end

  describe '#analytics_consent_accepted?' do
    before do
      allow(controller.cookies).to receive(:[]).with('crime_apply_cookies_consent').and_return(value)
    end

    context 'cookies has been accepted' do
      let(:value) { Cookies::SettingsForm::CONSENT_ACCEPT }

      it { expect(helper.analytics_consent_accepted?).to be(true) }
    end

    context 'cookies has been rejected' do
      let(:value) { Cookies::SettingsForm::CONSENT_REJECT }

      it { expect(helper.analytics_consent_accepted?).to be(false) }
    end
  end

  describe '#analytics_allowed?' do
    before do
      allow(helper).to receive(:analytics_consent_accepted?).and_return(consent_accepted)
    end

    context 'when the google analytics feature flag is not enabled' do
      let(:consent_accepted) { nil }

      before do
        allow(FeatureFlags).to receive(:google_analytics) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it { expect(helper.analytics_allowed?).to be(false) }
    end

    context 'when there is no GA_TRACKING_ID set' do
      let(:ga_tracking_id) { nil }
      let(:consent_accepted) { nil }

      it { expect(helper.analytics_allowed?).to be(false) }
    end

    context 'when there is GA_TRACKING_ID set' do
      context 'and consent has been granted by the user' do
        let(:consent_accepted) { true }

        it { expect(helper.analytics_allowed?).to be(true) }
      end

      context 'and consent has not been granted by the user' do
        let(:consent_accepted) { false }

        it { expect(helper.analytics_allowed?).to be(false) }
      end
    end
  end
end
