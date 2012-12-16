class AddSchoolAndYearToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school, :string
    add_column :users, :year, :string
    add_column :users, :major, :string
  end
end
