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
      products.build(
        sku: sku,
        quantity_available: 0,
        quantity_reserved: 0,
        quantity_shipped: 0
      )
    end

    def supply_product(sku:, quantity:)
      products.find { |p| p.sku == sku }.quantity_available += quantity
    end

    def reserve_products(order_number:, products:)
      too_many_reserved = shipments.select { |s| s.state == 'reserved' }.size > 4
      raise Inventory::Error, 'Too many reserved shipments' if too_many_reserved

      products.each do |sku, quantity_to_reserve|
        available = self.products.find { |p| p.sku == sku }.quantity_available
        raise Inventory::Error, 'Not enough quantity available' if available < quantity_to_reserve
      end

      shipments.build(order_number: order_number, state: 'reserved', products: products)

      products.each do |sku, quantity_to_reserve|
        product = self.products.find { |p| p.sku == sku }
        product.quantity_available -= quantity_to_reserve
        product.quantity_reserved += quantity_to_reserve
      end
    end

    def ship_products(order_number:)
      shipment = shipments.find { |s| s.order_number == order_number && s.state == 'reserved' }
      shipment.products.each do |sku, quantity_to_ship|
        reserved = products.find { |p| p.sku == sku }.quantity_reserved
        raise Inventory::Error if reserved < quantity_to_ship
      end

      shipment.products.each do |sku, quantity_to_ship|
        product = products.find { |p| p.sku == sku }
        product.quantity_reserved -= quantity_to_ship
        product.quantity_shipped += quantity_to_ship
      end

      shipment.state = 'shipped'
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
