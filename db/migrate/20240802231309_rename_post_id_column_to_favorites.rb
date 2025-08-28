class RenamePostIdColumnToFavorites < ActiveRecord::Migration[7.0]
  def change
    rename_column :favorites, :post_id, :content_id
  end
end
