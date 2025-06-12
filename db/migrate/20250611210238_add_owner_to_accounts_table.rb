class AddOwnerToAccountsTable < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :owner, null: true, foreign_key: { to_table: :accounts }, index: true
  end
end