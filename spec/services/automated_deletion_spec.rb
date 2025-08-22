require 'rails_helper'

RSpec.describe AutomatedDeletion do
  before do
    # app to be hard deleted
    CrimeApplication.create(reference: 700_000_1, documents: [], soft_deleted_at: 2.weeks.ago,
                            updated_at: 2.years.ago - 2.weeks)
    # app to be soft deleted
    CrimeApplication.create(reference: 700_000_2, documents: [], updated_at: 2.years.ago)
    # app to remain unaffected
    CrimeApplication.create(reference: 700_000_3, documents: [])
  end

  it 'deletes applications as required' do
    expect {
      described_class.call
    }.to change(CrimeApplication,
                :count).from(3).to(2)
    expect(CrimeApplication.find_by(reference: 700_000_1)).to be_nil
  end

  it 'adds a deletion entry for the deleted application' do
    expect { described_class.call }.to change(DeletionEntry, :count).from(0).to(1)
    deletion_entry = DeletionEntry.last
    expect(deletion_entry.business_reference).to eq('7000001')
    expect(deletion_entry.reason).to eq(DeletionReason::RETENTION_RULE.to_s)
  end

  it 'updates the soft_deleted_at for an application that has reached the retention period' do
    app_to_be_soft_deleted = CrimeApplication.find_by(reference: 700_000_2)

    expect { described_class.call }.to change {
      app_to_be_soft_deleted.reload.soft_deleted_at
    }.from(nil).to(be_within(1.second).of(Time.zone.now))
  end
end
