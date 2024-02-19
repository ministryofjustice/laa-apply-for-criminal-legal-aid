require 'rails_helper'

RSpec.describe Steps::Capital::PropertyTypeForm do
  subject(:form) { described_class.new }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([PropertyType::RESIDENTIAL, PropertyType::COMMERCIAL, PropertyType::LAND])
    end
  end
end
