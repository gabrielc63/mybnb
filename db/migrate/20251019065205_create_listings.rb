class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.decimal :price_per_night
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :max_guests
      t.integer :property_type
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
