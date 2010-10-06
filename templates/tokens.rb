class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.integer   :tokenizable_id, :null => false
      t.string    :tokenizable_type, :name, :null => false
      t.string    :token, :limit => 40, :null => false
      t.text      :data, :null => true
      t.datetime  :expires_at, :null => true
      t.datetime  :created_at
    end

    add_index :tokens, :tokenizable_type
    add_index :tokens, :tokenizable_id
    add_index :tokens, [:tokenizable_type, :tokenizable_id]
    add_index :tokens, :token
    add_index :tokens, :expires_at
  end

  def self.down
    drop_table :tokens
  end
end
