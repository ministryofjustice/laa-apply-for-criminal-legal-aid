require 'rails_helper'

RSpec.describe Steps::Income::BusinessesSummaryForm do
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

  describe '#add_business=(attribute)' do
    subject(:add_business) { form.add_business = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_business`' do
        expect { add_business }.not_to(change(form, :add_business))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_business` to `yes`' do
        expect { add_business }.to change(form, :add_business).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_business: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
