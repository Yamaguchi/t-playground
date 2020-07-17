class AddSummaryAndSignatureColumnsToCommand < ActiveRecord::Migration[6.0]
  def change
    add_column :commands, :summary, :string
    add_column :commands, :signature, :string
  end
end
