class AddColumnToContents < ActiveRecord::Migration[7.0]
  def change
    add_column :contents, :youtube_id, :string
  end
end
