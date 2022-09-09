class CreateBusArrivals < ActiveRecord::Migration[7.0]
  def change
    create_table :bus_arrivals do |t|

      t.timestamps
    end
  end
end
