resource "aws_budgets_budget" "account_budget" {
  name              = "account_budget"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "4"
  limit_unit        = "USD"
  time_period_start = "2025-06-25_00:00"
}