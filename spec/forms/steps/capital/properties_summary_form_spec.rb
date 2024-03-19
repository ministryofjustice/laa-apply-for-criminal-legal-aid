require 'rails_helper'

RSpec.describe Steps::Capital::PropertiesSummaryForm do
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

  describe '#add_property=(attribute)' do
    subject(:add_property) { form.add_property = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_property`' do
        expect { add_property }.not_to(change(form, :add_property))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_property` to `yes`' do
        expect { add_property }.to change(form, :add_property).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_property: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
