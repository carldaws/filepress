class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
