require 'rails_helper'

RSpec.describe Providers::ActiveOfficeChecker do
  subject { described_class.new(auth_info) }

  let(:auth_info) do
    double(
      office_codes:,
    )
  end

  let(:office_codes) { %w[1A123B 2A555X 2B234C 3B666Y] }
  let(:inactive_office_codes) { %w[2B234C 3B666Y] }

  describe '#active_office_codes' do
    before do
      allow(subject)
        .to receive(:inactive_office_codes)
        .and_return(inactive_office_codes)
    end

    context 'multi-code office' do
      it 'returns a list of active office codes' do
        active_codes = %w[1A123B 2A555X]
        expect(subject.active_office_codes).to match(active_codes)
      end

      context 'inactive codes are not in office code list' do
        let(:inactive_office_codes) { %w[3C345D 4C777Z] }

        it 'returns the an unaltered office code list' do
          active_codes = %w[1A123B 2A555X 2B234C 3B666Y]
          expect(subject.active_office_codes).to match(active_codes)
        end
      end

      context 'inactive office codes is nil (i.e. nothing on a given key in the flat file)' do
        let(:inactive_office_codes) { nil }

        it 'returns the full list of codes' do
          active_codes = %w[1A123B 2A555X 2B234C 3B666Y]
          expect(subject.active_office_codes).to match(active_codes)
        end

        context 'when there is a provider with only one office code' do
          let(:office_codes) { %w[1A123B] }

          it 'returns that one code' do
            active_codes = %w[1A123B]
            expect(subject.active_office_codes).to match(active_codes)
          end
        end
      end
    end

    context 'single code office' do
      let(:office_codes) { %w[1A123B] }

      it 'returns one office' do
        active_codes = %w[1A123B]

        expect(subject).not_to receive(:calculate_active_office_codes)
        expect(subject.active_office_codes).to match(active_codes)
      end
    end
  end
end
