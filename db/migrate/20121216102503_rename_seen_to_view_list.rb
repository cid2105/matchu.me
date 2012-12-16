class RenameSeenToViewList < ActiveRecord::Migration
  def change
  	rename_column :users, :unseen, :view_list
  end
end
