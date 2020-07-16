class CreateCommands < ActiveRecord::Migration[6.0]
  def change
    create_table :commands do |t|
      t.string :name
      t.string :description
      t.belongs_to :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
