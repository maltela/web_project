class CreateKeypairs < ActiveRecord::Migration
  def change
    create_table :keypairs do |t|

      t.timestamps
    end
  end
end
