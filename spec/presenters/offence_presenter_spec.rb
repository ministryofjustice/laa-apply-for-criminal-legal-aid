require 'rails_helper'

RSpec.describe OffencePresenter do
  subject { described_class.new(offence) }

  let(:offence) { Offence.find_by(name: name) }

  describe '#offence_class' do
    context 'for an offence with 1 class' do
      let(:name) { 'Common assault' }

      it 'presents the class' do
        expect(subject.offence_class).to eq('Class H')
      end
    end

    context 'for an offence with 2 classes' do
      let(:name) { 'Robbery' }

      it 'presents the classes' do
        expect(subject.offence_class).to eq('Class C or B')
      end
    end

    context 'for an offence with 3 classes' do
      let(:name) { 'Theft from a shop' }

      it 'presents the classes' do
        expect(subject.offence_class).to eq('Class F, G, or K')
      end
    end
  end
end
