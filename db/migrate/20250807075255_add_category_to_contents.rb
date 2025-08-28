class AddCategoryToContents < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:contents, :category_id)
      add_reference :contents, :category, null: false, foreign_key: true
    else
      # カラムは既にあるので、もし外部キー制約だけ貼りたいならここで追加
      unless foreign_key_exists?(:contents, :categories)
        add_foreign_key :contents, :categories
      end
    end
  end
end