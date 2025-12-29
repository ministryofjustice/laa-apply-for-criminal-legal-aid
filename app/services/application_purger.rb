class ApplicationPurger
  attr_reader :crime_application, :deleted_by, :deletion_reason

  def self.call(crime_application:, deleted_by:, deletion_reason:)
    new(crime_application:, deleted_by:, deletion_reason:).call
  end

  def initialize(crime_application:, deleted_by:, deletion_reason:)
    @crime_application = crime_application
    @deleted_by = deleted_by
    @deletion_reason = deletion_reason
  end
  private_class_method :new

  def call
    ActiveRecord::Base.transaction do
      delete_orphan_stored_documents
      log_deletion
      crime_application.destroy!
      publish_deletion_event
    end
  end

  private

  def delete_orphan_stored_documents
    orphan_documents.each do |document|
      Datastore::Documents::Delete.new(document:, deleted_by:, deletion_reason:).call
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

  def publish_deletion_event
    Datastore::Events::DraftDeleted.new(entity_id: crime_application.id,
                                        entity_type: crime_application.application_type,
                                        business_reference: crime_application.reference,
                                        deleted_by: deleted_by,
                                        reason: deletion_reason).call
  end
end
