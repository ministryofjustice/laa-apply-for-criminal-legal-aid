class AddLastJsaAppointmentDateToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :last_jsa_appointment_date, :date
  end
end
