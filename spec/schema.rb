ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.string :title
  end

  create_table :tokens do |t|
    t.integer   :tokenizable_id,            :null => false
    t.string    :tokenizable_type, :name,   :null => false
    t.string    :token,                     :null => false, :limit => 40
    t.text      :data,                      :null => true
    t.datetime  :expires_at,                :null => true
    t.datetime  :created_at
  end

  add_index :tokens, :token, :unique => true
end
