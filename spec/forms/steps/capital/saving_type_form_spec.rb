require 'rails_helper'

RSpec.describe Steps::Capital::SavingTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, savings:) }
  let(:savings) { class_double(Saving, where: existing_savings) }
  let(:existing_savings) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([SavingType::BANK, SavingType::BUILDING_SOCIETY, SavingType::CASH_ISA,
               SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE, SavingType::OTHER])
    end
  end

  describe '#save' do
    let(:saving_type) { SavingType.values.sample }
    let(:new_saving) { instance_double(Saving) }
    let(:existing_saving) { instance_double(Saving, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(savings).to receive(:create).with(saving_type:).and_return new_saving

      form.saving_type = saving_type
      form.save
    end

    context 'when client has no savings' do
      let(:saving_type) { 'none' }

      it 'returns true but does not set or create a saving' do
        expect(form.saving).to be_nil
        expect(savings).not_to have_received(:create)
      end
    end

    context 'when there are no savings of the saving type' do
      it 'a new saving of the saving type is created' do
        expect(form.saving).to be new_saving
        expect(savings).to have_received(:create).with(saving_type:)
      end
    end

    context 'when a saving of the type exists' do
      let(:existing_savings) { [existing_saving] }

      it 'is set as the saving' do
        expect(form.saving).to be existing_saving
        expect(savings).not_to have_received(:create)
      end

      context 'when the existing saving is complete' do
        let(:complete?) { true }

        it 'a new saving of the saving type is created' do
          expect(form.saving).to be new_saving
          expect(savings).to have_received(:create).with(saving_type:)
        end
      end
    end
  end
end
