data "terraform_remote_state" "prod" {
  backend = "http"

  config = {
    address = "https://gitlab.com/api/v4/projects/34369978/terraform/state/prod"
    username = "QuentinChartrin"
    password = "glpat-8rwWyYnzFWiWSEqA9PZL"
  }
}