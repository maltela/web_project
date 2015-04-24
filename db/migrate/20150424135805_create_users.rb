class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :salt_masterkey
      t.string :pubkey_user
      t.string :privkey_user_enc
      t.timestamps
    end
  end
end
