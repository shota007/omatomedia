# db/migrate/20240808025032_change_index_to_favorites.rb
class ChangeIndexToFavorites < ActiveRecord::Migration[7.0]
  # 既存テーブルへのインデックス操作はDDLトランザクション外で
  disable_ddl_transaction!

  def up
    # 目標：[:user_id, :content_id] のユニークインデックスを持つ状態
    if index_exists?(:favorites, [:user_id, :content_id], unique: true)
      # すでに望む状態なら何もしない
      return
    end

    # ユニークでないインデックスがあれば外す
    if index_exists?(:favorites, [:user_id, :content_id])
      remove_index :favorites, column: [:user_id, :content_id]
    end

    # ユニークで作成（既定のRails名を明示）
    add_index :favorites,
              [:user_id, :content_id],
              unique: true,
              algorithm: :concurrently,
              name: "index_favorites_on_user_id_and_content_id"
  end

  def down
    # ユニークを外して非ユニークに戻す（必要なら）
    if index_exists?(:favorites, [:user_id, :content_id], unique: true, name: "index_favorites_on_user_id_and_content_id")
      remove_index :favorites, name: "index_favorites_on_user_id_and_content_id"
    end

    unless index_exists?(:favorites, [:user_id, :content_id])
      add_index :favorites,
                [:user_id, :content_id],
                algorithm: :concurrently,
                name: "index_favorites_on_user_id_and_content_id"
    end
  end
end