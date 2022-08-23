require 'rails_helper'

RSpec.describe BasePresenter do
  describe '.present' do
    it 'calls the helper method passing self' do
      expect(
        ApplicationController.helpers
      ).to receive(:present).with('foobar', described_class)

      described_class.present('foobar')
    end
  end
end
