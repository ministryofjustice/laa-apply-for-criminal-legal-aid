require 'rails_helper'

RSpec.describe Steps::Case::IojPassportForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    { crime_application:, ioj_passport: }
  end

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  let(:kase) { Case.new }
  let(:ioj_passport) { [] }

  describe '#save' do
    it_behaves_like 'a has-one-association form',
                    association_name: :case,
                    expected_attributes: {
                      ioj: nil
                    }
  end
end
