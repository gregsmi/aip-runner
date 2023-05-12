
resource "local_file" "infra_json" {
  filename = "../docker/infrastructure.json"
  content  = <<-EOT
{
  %{~for i, f in local.INFRA_CONFIG_FIELDS_JSON~}
    ${f}%{if i != length(local.INFRA_CONFIG_FIELDS_JSON) - 1},%{endif}
  %{~endfor~}
}
EOT
}

resource "local_file" "infra_toml" {
  filename = "../configs/infrastructure.toml"
  content  = <<EOT
[infrastructure]
%{for f in local.INFRA_CONFIG_FIELDS_TOML~}
${f}
%{endfor~}
EOT
}

output "AZURE_CREDENTIALS" {
  value     = module.ci_cd_sp.credentials
  sensitive = true
}
