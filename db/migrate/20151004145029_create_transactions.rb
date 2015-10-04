class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string  :guid, limit: 36
      t.string  :src_vid
      t.integer :src_type
      t.string  :dst_vid
      t.integer :dst_type
      t.integer :category
      t.references :booking, index: true, foreign_key: true, default: nil
      t.string  :transaction_vid
      t.integer :transaction_type
      t.integer :status_mp
      t.integer :amount
      t.integer :fees

      t.timestamps null: false
    end
    add_index :transactions, :guid
    add_index :transactions, :src_vid
    add_index :transactions, :dst_vid
    add_index :transactions, :transaction_vid
  end
end
