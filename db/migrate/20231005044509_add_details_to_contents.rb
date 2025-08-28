class AddDetailsToContents < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:contents, :transcribed_text)
      add_column :contents, :transcribed_text, :string
    end
    unless column_exists?(:contents, :summarized_text)
      add_column :contents, :summarized_text, :string
    end
  end
end
