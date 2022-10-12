class CreateIojReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :ioj_reasons, id: :uuid do |t|
      t.string :types, array: true, default: []
      t.text :loss_of_liberty_justification
      t.text :suspended_sentence_justification
      t.text :loss_of_livelyhood_justification
      t.text :reputation_justification
      t.text :question_of_law_justification
      t.text :understanding_justification
      t.text :witness_tracing_justification
      t.text :expert_examination_justification
      t.text :interest_of_another_justification
      t.text :other_justification
      t.references :case, type: :uuid, foreign_key: true, null: true, index: { unique: true }

      t.timestamps
    end
  end
end