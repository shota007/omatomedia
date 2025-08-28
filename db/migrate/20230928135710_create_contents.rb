class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents do |t|
      t.string :transcribed_text
      t.string :summarized_text

      t.timestamps
    end
  end
end
