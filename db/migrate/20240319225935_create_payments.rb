class CreatePayments < ActiveRecord::Migration[7.0]
  def up
    create_table :payments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.string :type, null: false

      t.string :payment_type, null: false
      t.integer :amount, null: false
      t.string :frequency, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps

      # A crime application can only ever have a single payment_type per payment
      t.index [:crime_application_id, :type, :payment_type], unique: true, name: "index_payments_crime_application_id_and_payment_type"
    end

    ## Migrate existing data, avoid ActiveRecord due to STI classes having incorrect superclass
    [IncomePayment, IncomeBenefit, OutgoingsPayment].each do |klass|
      sql = <<-SQL
        INSERT INTO payments (type, crime_application_id, payment_type, amount, frequency, metadata, created_at, updated_at)
        SELECT '#{klass}', crime_application_id, payment_type, amount, frequency, metadata, created_at, updated_at
        FROM #{klass.to_s.underscore.pluralize}
      SQL

      Rails.logger.info("Migration SQL: #{sql}")
      results = ActiveRecord::Base.connection.execute(sql)
    end

    drop_table :income_payments
    drop_table :income_benefits
    drop_table :outgoings_payments
  end

  def down
    [:income_payments, :income_benefits, :outgoings_payments].each do |table|
      create_table table, id: :uuid do |t|
        t.references :crime_application, type: :uuid, foreign_key: true, null: false

        t.string :payment_type, null: false
        t.integer :amount, null: false
        t.string :frequency, null: false
        t.jsonb :metadata, default: {}, null: false

        t.timestamps

        # A crime application can only ever have a single payment_type per payment
        t.index [:crime_application_id, :payment_type], unique: true, name: "index_#{table}_crime_application_id_and_payment_type"
      end
    end

    ## Migrate existing data, avoid ActiveRecord due to STI classes having incorrect superclass
    [IncomePayment, IncomeBenefit, OutgoingsPayment].each do |klass|
      sql = <<-SQL
        INSERT INTO #{klass.to_s.underscore.pluralize} (crime_application_id, payment_type, amount, frequency, metadata, created_at, updated_at)
        SELECT crime_application_id, payment_type, amount, frequency, metadata, created_at, updated_at
        FROM payments
        WHERE type = '#{klass}'
      SQL

      Rails.logger.info("Migration SQL: #{sql}")
      results = ActiveRecord::Base.connection.execute(sql)
    end

    drop_table :payments
  end
end
