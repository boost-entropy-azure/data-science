
resource "azurerm_servicebus_namespace" "dfp-service-bus" {
  name                = join("-", [var.cluster_name, var.environment, "service-bus"])
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  tags = var.default_tags
}

resource "azurerm_servicebus_topic" "notices" {
  name         = "notices"
  namespace_id = azurerm_servicebus_namespace.dfp-service-bus.id

  enable_partitioning = true
}

resource "azurerm_servicebus_topic" "messages" {
  name         = "messages"
  namespace_id = azurerm_servicebus_namespace.dfp-service-bus.id

  enable_partitioning = true
}

resource "azurerm_servicebus_subscription" "notification-subscription" {
  name               = "notification-subscription"
  topic_id           = azurerm_servicebus_topic.notices.id
  max_delivery_count = 1
}