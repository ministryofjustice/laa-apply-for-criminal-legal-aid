require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentsSummaryForm do
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

  describe '#add_client_employment=(attribute)' do
    subject(:add_client_employment) { form.add_client_employment = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_client_employment`' do
        expect { add_client_employment }.not_to(change(form, :add_client_employment))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_client_employment` to `yes`' do
        expect { add_client_employment }.to change(form, :add_client_employment).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_client_employment: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
