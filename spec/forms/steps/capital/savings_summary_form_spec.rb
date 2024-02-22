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

  # describe 'validations' do
  #   it { is_expected.to validate_is_a(:add_saving, YesNoAnswer) }
  # end

  describe '#add_saving=(attribute)' do
    subject(:add_saving) { form.add_saving = value }

    context 'when value is not set' do
      let(:value) { nil }

      it 'sets `#account_holder` to `applicant`' do
        expect { add_saving }.not_to(change(form, :add_saving))
      end
    end

    context 'when value is set' do
      let(:value) { 'yes' }

      it 'does not set the account holder' do
        expect { add_saving }.to change(form, :add_saving).from(nil).to(YesNoAnswer::YES)
      end
    end
  end
end
