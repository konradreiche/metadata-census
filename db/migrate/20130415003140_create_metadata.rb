class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.string :name
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
