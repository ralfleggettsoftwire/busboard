class CreateTflApis < ActiveRecord::Migration[7.0]
  def change
    create_table :tfl_apis do |t|

      t.timestamps
    end
  end
end
