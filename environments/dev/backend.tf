terraform {
  backend "gcs" {
    bucket = "stratus-500215-tfstate"
    prefix = "foundation"
  }
}