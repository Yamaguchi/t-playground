class AddDefaultValueColumnToParameter < ActiveRecord::Migration[6.0]
  def change
    add_column :parameters, :default_value, :string
  end
end
