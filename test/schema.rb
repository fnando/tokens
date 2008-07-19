ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end
  
  create_table :tokens do |t|
    t.integer :tokenizable_id, :null => false
    t.string :tokenizable_type, :name, :null => false
    t.string :token, :limit => 40, :null => false
    t.text :data, :null => true
    t.datetime :expires_at, :null => true
    t.datetime :created_at
  end
end