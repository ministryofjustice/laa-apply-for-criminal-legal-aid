require 'rails_helper'

RSpec.describe Steps::Capital::AnswersForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: capital,
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:crime_application) { CrimeApplication.new(capital:) }
  let(:capital) { Capital.new }

  context 'with valid attributes' do
    before do
      allow(capital).to receive(:valid?).with(:check_answers).and_return(true)
    end

    context 'when `has_no_other_assets` is `yes`' do
      let(:attributes) { { has_no_other_assets: YesNoAnswer::YES.to_s } }

      it 'updates capital record' do
        expect(capital).to receive(:update).and_return(true)
        expect(subject.save!).to be(true)
      end
    end
  end

  context 'with invalid attributes' do
    context 'when `has_no_other_assets` is `no`' do
      let(:attributes) { { has_no_other_assets: YesNoAnswer::NO.to_s } }

      it 'does not update capital record' do
        expect(capital).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end

    context 'when `has_no_other_assets` is nil' do
      let(:attributes) { { has_no_other_assets: nil } }

      it 'does not update capital record' do
        expect(capital).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end

    context 'when `has_no_other_assets` is `yes` but answers are incomplete' do
      let(:attributes) { { has_no_other_assets: YesNoAnswer::YES.to_s } }

      it 'updates capital record' do
        expect(capital).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
