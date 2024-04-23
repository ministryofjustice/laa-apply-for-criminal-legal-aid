require 'rails_helper'

RSpec.describe Steps::Capital::OtherSavingTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, savings:) }
  let(:savings) { double }
  let(:saving_type) { SavingType.values.sample.to_s }
  let(:new_saving) { instance_double(Saving) }

  describe '#choices' do
    it 'returns saving types' do
      expect(form.choices).to match SavingType.values
    end
  end

  describe '#save' do
    before do
      allow(savings).to receive(:create!).with(saving_type:).and_return new_saving

      form.saving_type = saving_type
      form.save
    end

    context 'when a saving of the type exists' do
      it 'a new saving of the saving type is created' do
        expect(form.saving).to be new_saving
        expect(savings).to have_received(:create!).with(saving_type:)
      end
    end
  end
end
