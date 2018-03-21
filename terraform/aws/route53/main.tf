variable "zone_id" {}
variable "elb_masters" {}
variable "elb_agents" {}

resource "aws_route53_record" "dcos-dev-0" {
  zone_id = "${var.zone_id}"
  name = "dcos-dev-0.uat.teralytics.ch"
  type = "CNAME"
  ttl = "300"
  records = ["${var.elb_masters}"]
}

resource "aws_route53_record" "services-dev-0" {
  zone_id = "${var.zone_id}"
  name = "services-dev-0.uat.teralytics.ch"
  type = "CNAME"
  ttl = "300"
  records = ["${var.elb_agents}"]
}
