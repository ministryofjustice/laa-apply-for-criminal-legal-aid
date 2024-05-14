class AddColumnJobTitleToEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :employments, :job_title, :string
  end
end
