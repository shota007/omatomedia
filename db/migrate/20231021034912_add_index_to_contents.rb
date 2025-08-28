class AddIndexToContents < ActiveRecord::Migration[7.0]
  def change
    add_index :contents, :user_id
  end
end
