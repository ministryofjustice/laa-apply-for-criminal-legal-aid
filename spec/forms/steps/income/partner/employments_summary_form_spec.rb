require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentsSummaryForm do
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

  describe '#add_partner_employment=(attribute)' do
    subject(:add_partner_employment) { form.add_partner_employment = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'does not set `#add_partner_employment`' do
        expect { add_partner_employment }.not_to(change(form, :add_partner_employment))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'sets `#add_partner_employment` to `yes`' do
        expect { add_partner_employment }.to change(form, :add_partner_employment).from(nil).to(YesNoAnswer::YES)
      end
    end
  end

  describe '#partner_employments' do
    subject(:partner_employments) { form.partner_employments }

    before do
      expect(crime_application).to receive(:income).and_return(
        instance_double(Income, partner_employments: ['income_partner_employment'])
      )
    end

    it { is_expected.to eq ['income_partner_employment'] }
  end

  describe '#save' do
    context 'for valid details' do
      let(:attributes) do
        {
          add_partner_employment: 'yes',
        }
      end

      it 'updates the form' do
        expect(subject.save).to be(true)
      end
    end
  end
end
