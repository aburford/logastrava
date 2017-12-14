class CreateStaticData < ActiveRecord::Migration[5.1]
  def change
    create_table :static_data do |t|
      t.string :client_id
      t.string :client_secret
      t.timestamps
    end
  end
end
