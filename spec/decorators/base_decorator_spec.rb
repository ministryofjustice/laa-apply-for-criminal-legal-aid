require 'rails_helper'

RSpec.describe BaseDecorator do
  describe '.decorate' do
    it 'calls the helper method passing self' do
      expect(
        ApplicationController.helpers
      ).to receive(:decorate).with('foobar', described_class)

      described_class.decorate('foobar')
    end
  end
end
