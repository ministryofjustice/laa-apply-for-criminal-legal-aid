require 'rails_helper'

RSpec.describe Court, type: :model do
  describe '.find_by_name' do
    it 'is shorthand for `.find_by`' do
      expect(described_class).to receive(:find_by).with(name: 'Foobar')
      described_class.find_by(name: 'Foobar')
    end
  end

  describe '.all' do
    subject(:all) { described_class.all }

    it 'returns all courts' do
      expect(all.size).to eq(249)
    end

    it 'returns required courts as expected' do
      digest_of_expected_court_names = '2783b31a61666a79b810dc8ef95c61d1'

      expect(Digest::MD5.hexdigest(all.map(&:name).join)).to eq digest_of_expected_court_names
    end
  end
end
