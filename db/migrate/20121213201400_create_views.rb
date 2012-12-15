class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.integer :viewer_id
      t.integer :viewed_id

      t.timestamps
    end
  end
end
