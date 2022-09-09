class CreatePostcodeStops < ActiveRecord::Migration[7.0]
  def change
    create_table :postcode_stops do |t|

      t.timestamps
    end
  end
end
