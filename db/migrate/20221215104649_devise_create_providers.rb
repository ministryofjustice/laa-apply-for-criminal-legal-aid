# frozen_string_literal: true

class DeviseCreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers, id: :uuid do |t|
      t.timestamps null: false

      t.string :auth_provider, null: false # `saml` or some other in the future
      t.string :uid, null: false
      t.string :email
      t.string :description

      t.string :roles, array: true, default: [], null: false
      t.string :office_codes, array: true, default: [], null: false

      t.jsonb :settings, null: false, default: {}

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

    add_index :providers, [:auth_provider, :uid], unique: true
  end
end
