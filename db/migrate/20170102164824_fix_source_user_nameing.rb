class FixSourceUserNameing < ActiveRecord::Migration[5.0]
  def change
    remove_column :sources, :user
    add_column :sources, :username, :string
  end
end
