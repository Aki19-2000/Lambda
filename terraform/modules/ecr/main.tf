resource "aws_ecr_repository" "patient_service" {
  name = "patient-service"
}

resource "aws_ecr_repository" "appointment_service" {
  name = "appointment-service"
}
