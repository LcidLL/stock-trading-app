class AddConfirmableToTraders < ActiveRecord::Migration[7.2]
  def change
    add_column :traders, :confirmation_token, :string
    add_column :traders, :confirmed_at, :datetime
    add_column :traders, :confirmation_sent_at, :datetime
    add_column :traders, :unconfirmed_email, :string
    
    add_index :traders, :confirmation_token, unique: true
    
    reversible do |dir|
      dir.up do
        execute "UPDATE traders SET confirmed_at = NOW() WHERE confirmed_at IS NULL"
      end
    end
  end
end