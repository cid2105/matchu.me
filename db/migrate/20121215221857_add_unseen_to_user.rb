class AddUnseenToUser < ActiveRecord::Migration
  def change
    add_column :users, :unseen, :text
  end
end
