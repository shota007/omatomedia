class ChangeIndexToFavorites < ActiveRecord::Migration[7.0]
  def change
    add_index :favorites, [:user_id, :content_id]
  end
end
