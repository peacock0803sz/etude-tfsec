locals {
  apis = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
  ]
}

provider "google" {
  project = var.project_id
}

terraform {
  backend "gcs" {
    bucket = "etude-tfsec-peacock0803sz-tfstate"
  }
}

data "google_project" "project" {}

resource "google_project_service" "default" {
  for_each                   = toset(local.apis)
  service                    = each.value
  project                    = data.google_project.project.project_id
  disable_on_destroy         = false
  disable_dependent_services = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "time_sleep" "wait" {
  create_duration = "1m"

  depends_on = [google_project_service.default]
}

resource "google_project_iam_member" "bad_example" {
  member = "user:test@example.com"
  role   = "roles/editor"
}
