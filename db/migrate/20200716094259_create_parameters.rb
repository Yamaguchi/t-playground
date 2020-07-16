class CreateParameters < ActiveRecord::Migration[6.0]
  def change
    create_table :parameters do |t|
      t.string :name
      t.integer :index
      t.belongs_to :command, null: false, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
