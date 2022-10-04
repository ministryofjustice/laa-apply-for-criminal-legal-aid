require 'rails_helper'

RSpec.describe Court, type: :model do
  describe '.all' do
    subject(:all) { described_class.all }

    it 'returns required courts as expected' do
      expect(Digest::MD5.hexdigest(all.map(&:name).join)).to eq '4cdc39a4fa9cfe2aeb4984fe1dbab5d1'
    end
  end
end
