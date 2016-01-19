class ChangeEnumValuesForPurposeInFinancialTransactions < ActiveRecord::Migration
  def up
    # deposit id 2 => 3
    execute "UPDATE financial_transactions SET purpose=3 WHERE purpose = 2;"
  end
  def down
    # rental  id 2 => 1
    execute "UPDATE financial_transactions SET purpose=1 WHERE purpose = 2;"
    # deposit id 3 => 2
    execute "UPDATE financial_transactions SET purpose=2 WHERE purpose = 3;"
  end
end
