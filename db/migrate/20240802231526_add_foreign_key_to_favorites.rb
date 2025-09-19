# class AddForeignKeyToFavorites < ActiveRecord::Migration[7.0]
#   def change
#     add_foreign_key :contents, :users
#   end
# end
class AddForeignKeyToFavorites < ActiveRecord::Migration[7.0]
  def up
    # favorites.user_id -> users.id
    add_foreign_key :favorites, :users unless foreign_key_exists?(:favorites, :users)

    # favorites.content_id -> contents.id
    add_foreign_key :favorites, :contents unless foreign_key_exists?(:favorites, :contents)

    # おまけ：重複お気に入り防止のユニークインデックス（既にあれば何もしない）
    unless index_exists?(:favorites, [:user_id, :content_id], unique: true)
      add_index :favorites, [:user_id, :content_id], unique: true
    end
  end

  def down
    remove_index :favorites, [:user_id, :content_id] if index_exists?(:favorites, [:user_id, :content_id], unique: true)
    remove_foreign_key :favorites, :contents if foreign_key_exists?(:favorites, :contents)
    remove_foreign_key :favorites, :users    if foreign_key_exists?(:favorites, :users)
  end
end