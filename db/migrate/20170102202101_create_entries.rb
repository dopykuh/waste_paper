class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.references :source, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
