
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


resource "azurerm_servicebus_topic" "report-routing" {
  name         = "report-routing"
  namespace_id = azurerm_servicebus_namespace.dfp-service-bus.id

  enable_partitioning = true
}


resource "azurerm_servicebus_subscription" "newsfeed-notices" {
  name               = "newsfeed-notices"
  topic_id           = azurerm_servicebus_topic.notices.id
  max_delivery_count = 1
}

resource "azurerm_servicebus_subscription" "newsfeed-report-routing" {
  name               = "newsfeed-report-routing"
  topic_id           = azurerm_servicebus_topic.report-routing.id
  max_delivery_count = 1
}