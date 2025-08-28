class AddIndexToComments < ActiveRecord::Migration[7.0]
  def change
    add_index :comments, [:user_id, :contet_id]
  end
end
