ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.string :title
  end

  create_table :tokens do |t|
    t.string      :name, null: false
    t.belongs_to  :tokenizable, null: false, polymorphic: true
    t.string      :token, null: false
    t.text        :data, null: true
    t.datetime    :expires_at, null: true
    t.datetime    :created_at, null: false
  end

  add_index :tokens, :tokenizable_type
  add_index :tokens, :tokenizable_id
  add_index :tokens, [:tokenizable_type, :tokenizable_id]
  add_index :tokens, :token
  add_index :tokens, :expires_at
  add_index :tokens, [:tokenizable_id, :tokenizable_type, :name], unique: true
end
