class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :recipient_id
      t.string :sender_id
      t.string :cipher
      t.string :sig_recipient
      t.string :iv
      t.string :key_recipient_enc
      t.timestamps
    end
  end
end
