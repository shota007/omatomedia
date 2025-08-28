class ChangeColumnsAddNotNullOnContents < ActiveRecord::Migration[7.0]
  def change
    change_column_null :contents, :user_id, false
  end
end
