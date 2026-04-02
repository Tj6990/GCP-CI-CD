
package main

deny[msg] {
  input.kind == "Deployment"
  not input.metadata.labels.app
  msg := "Deployment must include metadata.labels.app"
}

deny[msg] {
  input.kind == "Deployment"
  not input.metadata.labels.color
  msg := "Deployment must include metadata.labels.color (blue/green)"
}
