require 'rails_helper'

RSpec.describe Steps::Client::BenefitCheckResultForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new }

  describe '#save' do
    it 'does not perform any operation, it only returns true' do
      expect(subject.save).to be(true)
    end
  end
end
