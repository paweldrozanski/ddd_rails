# inventory/lib/inventory.rb
class Inventory
  class Product < ActiveRecord::Base
    self.table_name = "inventory_products"
  end

  class Shipment < ActiveRecord::Base
    self.table_name = "inventory_shipments"
    serialize :data, Hash

    def products=(p)
      data[:products]=p
    end

    def products
      data[:products]
    end
  end

  class Store < ActiveRecord::Base
    self.table_name = "inventory_stores"
    has_many :shipments
    has_many :products
  end

  def self.register_product(sku:)
    ActiveRecord::Base.transaction do
      store = Store.first
        # TODO 
    end
  end


  def self.supply_product(sku:, quantity:)
    ActiveRecord::Base.transaction do
      store = Store.first
        # TODO
    end
  end

  def self.reserve_products(order_number:, products:)
    ActiveRecord::Base.transaction do
      store = Store.first
        # TODO
    end
  end

  def self.ship_products(order_number:)
    ActiveRecord::Base.transaction do
      store = Store.first
        # TODO
    end
  end

  TEST = Proc.new do
    Inventory::Store.delete_all
    Inventory::Product.delete_all
    Inventory::Shipment.delete_all

    Inventory::Store.create!(name: "Arkency")

    Inventory.register_product(sku: "WORKSHOP")
    Inventory.register_product(sku: "BOOK")

    Inventory.supply_product(sku: "WORKSHOP", quantity: 20)
    Inventory.supply_product(sku: "BOOK", quantity: 10)

    begin
      # not enough quantity of WORKSHOP to reserve
      Inventory.reserve_products(order_number: "0", products: {"WORKSHOP" => 21})
    rescue Inventory::Error
    end

    Inventory.reserve_products(order_number: "1", products: {"WORKSHOP" => 3})
    Inventory.reserve_products(order_number: "2", products: {"WORKSHOP" => 3})
    Inventory.reserve_products(order_number: "3", products: {"WORKSHOP" => 3})
    Inventory.reserve_products(order_number: "4", products: {"WORKSHOP" => 3})

    begin
      # Max 4 orders/shipment can be reserved at given time
      Inventory.reserve_products(order_number: "5", products: {"WORKSHOP" => 3})
    rescue Inventory::Error
    end

    Inventory.ship_products(order_number: "1")
    Inventory.ship_products(order_number: "2")
    Inventory.ship_products(order_number: "3")
    Inventory.ship_products(order_number: "4")

    Inventory.reserve_products(order_number: "5", products: {"WORKSHOP" => 3})
    Inventory.ship_products(order_number: "5")


    begin
      # Not enough quantity of BOOK to reserve
      Inventory.reserve_products(order_number: "5", products: {"WORKSHOP" => 5, "BOOK" => 11})
    rescue Inventory::Error
    end

    # WORKSHOP was not reserved in previous operation and the quantity is still available
    Inventory.reserve_products(order_number: "5", products: {"WORKSHOP" => 5})
  end
end
