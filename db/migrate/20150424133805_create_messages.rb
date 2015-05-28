class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :recipient_id
      t.integer :sender_id
      t.string :cipher, :limit => 20000
      t.string :sig_recipient
      t.string :iv
      t.string :key_recipient_enc, :limit => 500
      t.boolean :read, :default => false
      t.timestamps
    end
  end
end
