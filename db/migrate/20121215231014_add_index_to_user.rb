class AddIndexToUser < ActiveRecord::Migration
  def change
    add_column :users, :index, :integer
  end
end
