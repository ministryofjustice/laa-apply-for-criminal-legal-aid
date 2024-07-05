class AddDetailsToBusinesses < ActiveRecord::Migration[7.0]
  def change
    add_column :businesses, :trading_name, :string
    add_column :businesses, :address, :jsonb
    add_column :businesses, :description, :text
    add_column :businesses, :trading_start_date, :date
    add_column :businesses, :has_additional_owners, :string
    add_column :businesses, :additional_owners, :text
    add_column :businesses, :has_employees, :string
    add_column :businesses, :number_of_employees, :integer
    add_column :businesses, :percentage_profit_share, :float

    add_column :businesses, :salary, :jsonb
    add_column :businesses, :total_income_share_sales, :jsonb
    add_column :businesses, :turnover, :jsonb
    add_column :businesses, :drawings, :jsonb
    add_column :businesses, :profit, :jsonb 
  end
end
