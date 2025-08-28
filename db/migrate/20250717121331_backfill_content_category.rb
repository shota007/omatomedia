class BackfillContentCategory < ActiveRecord::Migration[7.0]
  def up
    default_id = Category.find_or_create_by!(name: "未分類").id
    Content.where(category_id: nil).update_all(category_id: default_id)
  end

  def down
    Content.where(category_id: Category.find_by(name: "未分類")&.id).update_all(category_id: nil)
  end
end