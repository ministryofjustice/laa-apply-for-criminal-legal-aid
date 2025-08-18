require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'AutomateDeletionSpec' do
  before do
    CrimeApplication.create(reference: 700_000_1, documents: [], soft_deleted_at: 2.weeks.ago, updated_at: 2.years.ago - 2.weeks)
    CrimeApplication.create(reference: 700_000_2, documents: [], updated_at: 2.years.ago)
    CrimeApplication.create(reference: 700_000_3, documents: [])
  end

  it 'deletes applications as required' do
    expect(CrimeApplication.count).to eq(2) # as default scope does not include soft deleted applications
    expect(DeletionEntry.count).to eq(0)

    run_task
    expect(CrimeApplication.count).to eq(1)
    expect(DeletionEntry.count).to eq(1)
  end

  it 'adds a deletion entry for the deleted application' do
    run_task

    deletion_entry = DeletionEntry.last
    expect(deletion_entry.business_reference).to eq('7000001')
    expect(deletion_entry.reason).to eq(DeletionReason::RETENTION_RULE.to_s)
  end

  it 'updates the soft_deleted_at for an application that has reached the retention period' do
    app_to_be_soft_deleted = CrimeApplication.unscoped.find_by(reference: 700_000_2) # as default scope does not include soft deleted applications
    expect(app_to_be_soft_deleted.soft_deleted_at).to be_nil
    run_task
    expect(CrimeApplication.unscoped.find_by(reference: 700_000_2).soft_deleted_at).to be_within(1.second).of(Time.zone.now)
  end
end

def run_task
  Rake::Task['automate_deletion'].invoke
end