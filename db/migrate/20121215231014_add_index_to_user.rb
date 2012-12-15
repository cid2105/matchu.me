class AddIndexToUser < ActiveRecord::Migration
  def change
    add_column :users, :index, :integer, :default => 0
  end
end
