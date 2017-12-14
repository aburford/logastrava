class AddPasswordDigestToUser < ActiveRecord::Migration[5.1]
  def change
		add_column :users, :password_digest, :string
		remove_column :users, :encrypted_password
		remove_column :users, :salt
  end
end
