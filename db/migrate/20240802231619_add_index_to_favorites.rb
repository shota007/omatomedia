class AddIndexToFavorites < ActiveRecord::Migration[7.0]
  def up
    # 既に前のマイグレーションで追加済みなので、存在チェックして何もしない
    return if index_exists?(:favorites, [:user_id, :content_id])
    add_index :favorites, [:user_id, :content_id]
  end

  def down
    remove_index :favorites, column: [:user_id, :content_id] if index_exists?(:favorites, [:user_id, :content_id])
  end
end