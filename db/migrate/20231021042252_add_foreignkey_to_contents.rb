class AddForeignkeyToContents < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :contents, :users
  end
end
