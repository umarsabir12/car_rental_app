class RemoveUsbPortsFromCars < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :usb_ports, :integer
  end
end
