class AddTypeAndRequiredColumnsToParameter < ActiveRecord::Migration[6.0]
  def change
    add_column :parameters, :parameter_type, :string
    add_column :parameters, :required, :bool
  end
end
