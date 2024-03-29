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

# WORKSHOP was not reserved in previous operation
Inventory.reserve_products(order_number: "5", products: {"WORKSHOP" => 5})
