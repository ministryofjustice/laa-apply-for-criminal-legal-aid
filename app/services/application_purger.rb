class ApplicationPurger
  attr_reader :crime_application, :log_context, :deleted_by, :deletion_reason

  def self.call(crime_application, log_context, deleted_by, deletion_reason)
    new(crime_application, log_context, deleted_by, deletion_reason).call
  end

  def initialize(crime_application, log_context, deleted_by, deletion_reason)
    @crime_application = crime_application
    @log_context = log_context
    @deleted_by = deleted_by
    @deletion_reason = deletion_reason
  end
  private_class_method :new

  def call
    ActiveRecord::Base.transaction do
      delete_orphan_stored_documents
      log_deletion
      crime_application.destroy!
    end
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, log_context:, deleted_by:, deletion_reason:).call
    end
  end

  def orphan_documents
    crime_application.documents.stored.not_submitted
  end

  def log_deletion
    DeletionEntry.create!(
      record_id: crime_application.id,
      record_type: RecordType::APPLICATION.to_s,
      business_reference: crime_application.reference,
      deleted_by: deleted_by,
      reason: deletion_reason
    )
  end
end
