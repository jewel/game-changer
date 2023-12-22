class InitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :icon
      t.string :password, null: false
      t.timestamp :last_login
      t.integer :age
      t.timestamp :deleted_at
      t.timestamps
    end

    create_table :games do |t|
      t.string :name, null: false
      t.string :icon
      t.integer :min_age
      t.timestamp :deleted_at
      t.string :command
      t.text :environment
      t.references :default_version, null: true
      t.timestamps
    end

    create_table :versions do |t|
      t.references :game, null: false
      t.string :number, null: false
      t.integer :size, null: false
      t.json :bucket, null: false
      t.timestamp :deleted_at
      t.timestamps
    end

    create_table :saves do |t|
      t.references :user, null: false
      t.references :version, null: false
      t.references :station, null: false
      t.integer :size
      t.json :bucket, null: false
      t.timestamps
      t.timestamp :deleted_at
    end

    create_table :stations do |t|
      t.string :hostname, null: false
      t.timestamp :last_seen, null: false
      t.timestamps
      t.timestamp :deleted_at
    end

    create_table :sessions do |t|
      t.references :user, null: false
      t.references :version, null: false
      t.timestamp :started_at, null: false
      t.integer :duration, null: false
      t.integer :idle_time, null: false
    end
  end
end
