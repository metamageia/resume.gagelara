module "core" {
  source = "./modules/core"
}

module "visitor-counter" {
  source = "./modules/visitor-counter"
}
output "api_url" {
  value = module.visitor-counter.api_url
}