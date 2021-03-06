class CreatePaymentLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_line_items do |t|
      t.references :payment, foreign_key: true
      t.references :buyable, polymorphic: true
      t.monetize :price

      t.timestamps
    end
  end
end
