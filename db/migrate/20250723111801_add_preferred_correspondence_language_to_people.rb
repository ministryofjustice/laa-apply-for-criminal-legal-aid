class AddPreferredCorrespondenceLanguageToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :preferred_correspondence_language, :string
  end
end
