class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title, index: true, null: false
      t.references :author, foreign_key: true, null: false

      t.timestamps
    end
  end
end
