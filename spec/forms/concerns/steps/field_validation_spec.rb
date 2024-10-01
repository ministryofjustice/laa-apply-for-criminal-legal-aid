require 'rails_helper'

RSpec.describe Steps::FieldValidation do
  subject(:assessable) do
    assessable_class.new(number_attribute:)
  end

  let(:assessable_class) do
    Struct.new(:number_attribute) do
      include Steps::FieldValidation
    end
  end

  let(:number_attribute) { nil }

  describe '#numericality' do
    subject(:numericality) { assessable.numericality(:number_attribute, options) }

    let(:options) { {} }

    context 'when the value is not a number' do
      let(:number_attribute) { 'one' }

      it { is_expected.to eq([:not_a_number]) }
    end

    context 'when the value must be greater than' do
      let(:options) { { greater_than: 0 } }
      let(:number_attribute) { '0' }

      it { is_expected.to eq([:greater_than]) }
    end
  end
end
