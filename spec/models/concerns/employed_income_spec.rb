require 'rails_helper'

RSpec.describe EmployedIncome do
  subject(:assessable) do
    assessable_class.new(employment_status:, partner_employment_status:)
  end

  let(:assessable_class) do
    Struct.new(:employment_status, :partner_employment_status) do
      include EmployedIncome
    end
  end

  let(:employment_status) { nil }
  let(:partner_employment_status) { nil }

  describe '#require_client_in_armed_forces?' do
    subject(:require_client_in_armed_forces?) { assessable.require_client_in_armed_forces? }

    context 'when the client employment status is only `employed`' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      it { is_expected.to be true }
    end

    context 'when the client employment status is more than `employed`' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

      it { is_expected.to be false }
    end
  end

  describe '#require_partner_in_armed_forces?' do
    subject(:require_partner_in_armed_forces?) { assessable.require_partner_in_armed_forces? }

    context 'when the partner employment status is only `employed`' do
      let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      context "and the client's employment status does not include `self employed`" do
        let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

        it { is_expected.to be true }
      end

      context "and the client's employment status includes `self employed`" do
        let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

        it { is_expected.to be false }
      end
    end

    context 'when the partner employment status is more than `employed`' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }
      let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s] }

      it { is_expected.to be false }
    end
  end
end
