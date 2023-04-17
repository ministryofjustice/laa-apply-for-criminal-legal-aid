require 'rails_helper'

RSpec.describe PersonWithDob do
  let(:test_class) do
    Struct.new(:date_of_birth) { include PersonWithDob }
  end

  let(:person) { test_class.new(dob) }

  describe '#under18?' do
    context 'for an under 18 date of birth' do
      let(:dob) { 17.years.ago }

      it { expect(person.under18?).to be(true) }
    end

    context 'for an over 18 date of birth' do
      let(:dob) { 19.years.ago }

      it { expect(person.under18?).to be(false) }
    end
  end
end
