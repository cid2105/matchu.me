class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :liker_id
      t.integer :likee_id

      t.timestamps
    end
  end
end
