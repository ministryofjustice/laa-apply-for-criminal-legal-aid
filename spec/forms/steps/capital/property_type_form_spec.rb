require 'rails_helper'

RSpec.describe Steps::Capital::PropertyTypeForm do
  subject(:form) { described_class.new }

  # let(:arguments) do
  #   {
  #     crime_application:,
  #     property_type:
  #   }
  # end
  #
  # let(:crime_application) { instance_double(CrimeApplication, properties:) }
  # let(:properties) { Property.new }
  #
  # let(:property_type) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([PropertyType::RESIDENTIAL, PropertyType::COMMERCIAL, PropertyType::LAND])
    end
  end
end
