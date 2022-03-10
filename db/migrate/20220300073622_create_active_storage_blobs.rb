class CreateActiveStorageBlobs < ActiveRecord::Migration[5.2]
  def change
    create_table :active_storage_blobs do |t|
      t.string :url
      t.string :checksum
      t.timestamps
    end
  end
end
