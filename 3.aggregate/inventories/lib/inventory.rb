# frozen_string_literal: true

# Class Inventory is root aggregate
class Inventory
  class Error < StandardError; end

  # Entity
  class Product < ActiveRecord::Base
    self.table_name = 'inventory_products'
  end

  # Entity
  class Shipment < ActiveRecord::Base
    self.table_name = 'inventory_shipments'
    serialize :data, Hash

    def products=(hash)
      data[:products] = hash
    end

    def products
      data[:products]
    end
  end

  # Entity
  class Store < ActiveRecord::Base
    self.table_name = 'inventory_stores'
    has_many :products,  autosave: true
    has_many :shipments, autosave: true

    def register_product(sku:)
      # TODO
    end

    def supply_product(sku:, quantity:)
      # TODO
    end

    def reserve_products(order_number:, products:)
      # TODO
    end

    def ship_products(order_number:)
      # TODO
    end
  end

  def self.register_product(sku:)
    ActiveRecord::Base.transaction do
      s = Store.lock.first
      s.register_product(sku: sku)
      s.save!
    end
  end

  def self.reserve_products(order_number:, products:)
    ActiveRecord::Base.transaction do
      s = Store.lock.first
      s.reserve_products(order_number: order_number, products: products)
      s.save!
    end
  end

  def self.ship_products(order_number:)
    ActiveRecord::Base.transaction do
      s = Store.lock.first
      s.ship_products(order_number: order_number)
      s.save!
    end
  end

  def self.supply_product(sku:, quantity:)
    ActiveRecord::Base.transaction do
      s = Store.lock.first
      s.supply_product(sku: sku, quantity: quantity)
      s.save!
    end
  end

  TEST = proc do
    Inventory::Store.delete_all
    Inventory::Product.delete_all
    Inventory::Shipment.delete_all

    Inventory::Store.create!(name: 'Arkency')

    Inventory.register_product(sku: 'WORKSHOP')
    Inventory.register_product(sku: 'BOOK')

    Inventory.supply_product(sku: 'WORKSHOP', quantity: 20)
    Inventory.supply_product(sku: 'BOOK', quantity: 10)

    begin
      # not enough quantity of WORKSHOP to reserve
      Inventory.reserve_products(order_number: '0', products: { 'WORKSHOP' => 21 })
    rescue Inventory::Error
    end

    Inventory.reserve_products(order_number: '1', products: { 'WORKSHOP' => 3 })
    Inventory.reserve_products(order_number: '2', products: { 'WORKSHOP' => 3 })
    Inventory.reserve_products(order_number: '3', products: { 'WORKSHOP' => 3 })
    Inventory.reserve_products(order_number: '4', products: { 'WORKSHOP' => 3 })

    begin
      # Max 4 orders/shipment can be reserved at given time
      Inventory.reserve_products(order_number: '5', products: { 'WORKSHOP' => 3 })
    rescue Inventory::Error
    end

    Inventory.ship_products(order_number: '1')
    Inventory.ship_products(order_number: '2')
    Inventory.ship_products(order_number: '3')
    Inventory.ship_products(order_number: '4')

    Inventory.reserve_products(order_number: '5', products: { 'WORKSHOP' => 3 })
    Inventory.ship_products(order_number: '5')

    begin
      # Not enough quantity of BOOK to reserve
      Inventory.reserve_products(order_number: '5', products: { 'WORKSHOP' => 5, 'BOOK' => 11 })
    rescue Inventory::Error
    end

    # WORKSHOP was not reserved in previous operation
    Inventory.reserve_products(order_number: '5', products: { 'WORKSHOP' => 5 })
  end
end
