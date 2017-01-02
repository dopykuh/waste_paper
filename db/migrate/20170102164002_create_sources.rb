class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.string :address
      t.string :user
      t.string :password
      t.integer :port
      t.string :authentication
      t.boolean :ssl
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
