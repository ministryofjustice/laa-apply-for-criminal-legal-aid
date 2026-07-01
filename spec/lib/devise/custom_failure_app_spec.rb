require 'rails_helper'

RSpec.describe Devise::CustomFailureApp do
  describe '#redirect' do
    subject(:redirect_request) { failure_app.redirect }

    let(:failure_app) { described_class.new }
    let(:attempted_path) { '/applications' }

    before do
      allow(failure_app).to receive_messages(
        warden_message: :unauthenticated,
        attempted_path: attempted_path,
        unauthenticated_errors_path: '/errors/unauthenticated'
      )
      allow(failure_app).to receive(:redirect_to)
      allow(Rails.logger).to receive(:debug)
    end

    it 'stores location when path size is within limits' do
      expect(failure_app).to receive(:store_location!)
      redirect_request
    end

    context 'when attempted path exceeds the session-safe size' do
      let(:attempted_path) { "/test?#{'a' * 3000}" }

      it 'skips storing location and still redirects' do
        expect(failure_app).not_to receive(:store_location!)
        expect(Rails.logger).to receive(:warn).with(
          /Skipping store_location! for oversized attempted path/
        )
        expect(failure_app).to receive(:redirect_to).with('/errors/unauthenticated')

        redirect_request
      end
    end
  end
end
