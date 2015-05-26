class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users, id: false)  do |t|
      t.primary_key :user_id
      t.index :identity, :unique=>true
      t.string :identity
      t.string :salt_masterkey
      t.string :pubkey_user, :limit => 500
      t.string :privkey_user_enc, :limit => 500
      t.timestamps
    end
  end
end
