class CreateFoos < ActiveRecord::Migration[5.2]
  def change
    create_table :foos do |t|
      t.references :options, polymorphic: true

      t.timestamps
    end
  end
end
