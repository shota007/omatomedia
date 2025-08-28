class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.integer :content_id, null: false
      t.string :comment

      t.timestamps
    end
  end
end
