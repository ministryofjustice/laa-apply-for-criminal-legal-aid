require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentsSummaryForm do
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

  describe '#add_investment=(attribute)' do
    subject(:add_investment) { form.add_investment = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_investment`' do
        expect { add_investment }.not_to(change(form, :add_investment))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_investment` to `yes`' do
        expect { add_investment }.to change(form, :add_investment).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_investment: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
