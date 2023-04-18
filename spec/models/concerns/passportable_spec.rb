require 'rails_helper'

RSpec.describe Passportable do
  let(:test_class) do
    Class.new { include Passportable }
  end

  let(:crime_application) { test_class.new }

  describe '#means_passported?' do
    let(:means_double) { double }

    before do
      allow(
        Passporting::MeansPassporter
      ).to receive(:new).with(crime_application).and_return(means_double)
    end

    it 'delegates to the MeansPassporter' do
      expect(means_double).to receive(:passported?)

      crime_application.means_passported?
    end
  end

  describe '#ioj_passported?' do
    let(:ioj_double) { double }

    before do
      allow(
        Passporting::IojPassporter
      ).to receive(:new).with(crime_application).and_return(ioj_double)
    end

    it 'delegates to the IojPassporter' do
      expect(ioj_double).to receive(:passported?)

      crime_application.ioj_passported?
    end
  end
end
