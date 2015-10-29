class CreateMedia < ActiveRecord::Migration
  def change
    create_table :atomic_cms_media do |t|
      t.string :media_type
      t.attachment :file
      t.timestamps
    end
  end
end
