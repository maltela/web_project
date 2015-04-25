class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users, id: false)  do |t|
      t.primary_key :user_id
      t.string :identity, :unique=>true
      t.string :salt_masterkey
      t.string :pubkey_user
      t.string :privkey_user_enc
      t.timestamps
    end
  end
end
