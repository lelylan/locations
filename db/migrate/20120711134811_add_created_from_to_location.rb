class AddCreatedFromToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :created_from, :string
  end
end
