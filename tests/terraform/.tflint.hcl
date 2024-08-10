plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_comment_syntax" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}
