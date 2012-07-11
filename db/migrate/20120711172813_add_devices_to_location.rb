class AddDevicesToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :devices, :text
  end
end
