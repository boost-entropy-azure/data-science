output "hostname" {
  description = "The fully qualified domain name of the redis server"
  value       = azurerm_redis_cache.analytics.hostname
}

output "port" {
  description = "The port number of the redis server"
  value       = azurerm_redis_cache.analytics.ssl_port
}

output "secret" {
  description = "The secret primary connection key"
  value       = azurerm_redis_cache.analytics.primary_access_key
  sensitive   = true
}