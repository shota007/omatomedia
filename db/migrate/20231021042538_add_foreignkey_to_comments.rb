class AddForeignkeyToComments < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :comments, :users
    add_foreign_key :comments, :contents
  end
end
