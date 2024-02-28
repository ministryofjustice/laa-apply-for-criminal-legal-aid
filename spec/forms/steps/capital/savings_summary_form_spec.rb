require 'rails_helper'

RSpec.describe Steps::Capital::SavingsSummaryForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  describe '#add_saving=(attribute)' do
    subject(:add_saving) { form.add_saving = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_saving`' do
        expect { add_saving }.not_to(change(form, :add_saving))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_saving` to `yes`' do
        expect { add_saving }.to change(form, :add_saving).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_saving: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
