class ChangeCategoryIdNullOnContents < ActiveRecord::Migration[7.0]
  def up
    # 念のためもう一度バックフィル
    default_id = Category.find_or_create_by!(name: "未分類").id
    Content.where(category_id: nil).update_all(category_id: default_id)

    change_column_null :contents, :category_id, false
  end

  def down
    change_column_null :contents, :category_id, true
  end
end