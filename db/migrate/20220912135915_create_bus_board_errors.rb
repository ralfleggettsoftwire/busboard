class CreateBusBoardErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :bus_board_errors do |t|

      t.timestamps
    end
  end
end
