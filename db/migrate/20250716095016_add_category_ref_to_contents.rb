class AddCategoryRefToContents < ActiveRecord::Migration[7.0]
  def change
    add_reference :contents, :category, foreign_key: true, null: true
  end
end
