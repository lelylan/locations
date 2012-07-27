class AddCreatedFromToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :resource_owner_id, :string
  end
end
