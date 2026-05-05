require 'rails_helper'

RSpec.describe Summary::Components::OffenceTypeAndClassAnswer do
  subject(:component) { described_class.new(:offence_type_and_class, offence) }

  let(:offence) { instance_double(Charge, offence_name:, offence_class:) }

  describe '#answer_text' do
    context 'when both offence name and class are present' do
      let(:offence_name) { 'Common assault' }
      let(:offence_class) { 'C' }

      it 'renders the offence name and class together' do
        result = component.answer_text
        expect(result).to include('Common assault')
        expect(result).to include('C')
      end
    end

    context 'when offence class is nil' do
      let(:offence_name) { 'Common assault' }
      let(:offence_class) { nil }

      it 'renders a "not determined" tag for the class' do
        result = component.answer_text
        expect(result).to include('Common assault')
        expect(result).to include('Not determined')
      end
    end

    context 'when both offence name and class are nil' do
      let(:offence_name) { nil }
      let(:offence_class) { nil }

      it 'renders an empty type paragraph and a "not determined" tag for the class' do
        result = component.answer_text
        expect(result).to include('Not determined')
      end
    end
  end
end
