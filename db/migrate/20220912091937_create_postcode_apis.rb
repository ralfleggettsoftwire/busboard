class CreatePostcodeApis < ActiveRecord::Migration[7.0]
  def change
    create_table :postcode_apis do |t|

      t.timestamps
    end
  end
end
