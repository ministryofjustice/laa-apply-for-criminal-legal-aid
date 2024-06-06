require 'rails_helper'

RSpec.describe PartnerDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:, kase:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when case type is nil' do
      let(:case_type) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }
  end

  describe '#validate' do
    subject(:validate) { validator.validate }
  end
end
