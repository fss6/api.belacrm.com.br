class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :email
      t.string :identifier
      t.string :invitation_token
      t.datetime :invitation_sent_at
      t.datetime :plan_expires_at
      t.references :plan, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end