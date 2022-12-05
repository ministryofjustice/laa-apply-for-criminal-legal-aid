class DeviseCreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers, id: :uuid do |t|
      t.timestamps null: false

      t.references :firm, type: :uuid, foreign_key: true, null: false

      t.string :email, null: false
      t.string :username, null: false
      t.string :description, null: false

      t.string :selected_office_code

      # Unsure we may need this, adding for now
      t.string :first_name
      t.string :last_name

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.datetime :locked_at
    end

    add_index :providers, [:firm_id, :email], unique: true
  end
end
