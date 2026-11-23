# Ticket: "A harmless rename in a refactor PR wants to destroy + recreate resources."
# Uses the built-in terraform_data resource so the lab runs with real state, offline.
# STEP 1 (setup.sh) applies this file as-is. STEP 2 renames "artifact_store" -> "artifacts".
resource "terraform_data" "artifact_store" {
  input = {
    name = "iac-course-artifacts"
    tier = "standard"
  }
}
