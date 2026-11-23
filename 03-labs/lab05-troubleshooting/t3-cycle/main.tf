# Ticket: "App and DB security groups must allow each other. Plan errors out."
resource "aws_security_group" "app" {
  name   = "app"
  vpc_id = "vpc-0123456789abcdef0"

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }
}

resource "aws_security_group" "db" {
  name   = "db"
  vpc_id = "vpc-0123456789abcdef0"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}
