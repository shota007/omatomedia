# class AddIndexToComments < ActiveRecord::Migration[7.0]
#   def change
#     add_index :comments, [:user_id, :contet_id]
#   end
# end
# db/migrate/20231021040456_add_index_to_comments.rb
class AddIndexToComments < ActiveRecord::Migration[7.0]
  def change
    # 安全に：列がある方へだけ index を貼る
    if column_exists?(:comments, :content_id)
      add_index :comments, [:user_id, :content_id], name: "index_comments_on_user_id_and_content_id" unless index_exists?(:comments, [:user_id, :content_id])
    elsif column_exists?(:comments, :post_id)
      # 万一 schema が :post_id なら、暫定でこちらに貼る（将来 rename 予定）
      add_index :comments, [:user_id, :post_id], name: "index_comments_on_user_id_and_post_id" unless index_exists?(:comments, [:user_id, :post_id])
    else
      raise "comments に content_id も post_id も見つかりません"
    end
  end
end