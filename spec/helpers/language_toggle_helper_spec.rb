require 'rails_helper'

RSpec.describe LanguageToggleHelper, type: :helper do
  context 'when the welsh translation feature flag is not enabled' do
    before do
      allow(FeatureFlags).to receive(:welsh_translation) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    it { expect(helper.language_toggle_allowed?).to be(false) }
  end
end
