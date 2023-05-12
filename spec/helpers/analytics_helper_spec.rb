require 'rails_helper'

RSpec.describe AnalyticsHelper, type: :helper do
  describe '#analytics_tracking_id' do
    it 'retrieves the configuration variable' do
      expect(Rails.configuration.x.analytics).to receive(:ga_tracking_id)
      helper.analytics_tracking_id
    end
  end
end
