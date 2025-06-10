class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :price_cents
      t.integer :interval, default: 0, null: false
      t.integer :client_limit, null: true
      t.integer :profissional_limit, null: true
      t.integer :appointments_limit, null: true
      t.boolean :whatsapp_notifications, default: false
      t.boolean :email_notifications, default: false
      t.text :description

      t.timestamps
    end
  end
end
