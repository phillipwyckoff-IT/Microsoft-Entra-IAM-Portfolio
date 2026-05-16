[1m  # azuread_conditional_access_policy.mfa_for_admins[0m will be created
[0m  [32m+[0m[0m resource "azuread_conditional_access_policy" "mfa_for_admins" {
      [32m+[0m[0m display_name = "SEC-CAP-01-MFA-For-Administrators"
      [32m+[0m[0m id           = (known after apply)
      [32m+[0m[0m state        = "enabled"

      [32m+[0m[0m conditions {
          [32m+[0m[0m client_app_types = [
              [32m+[0m[0m "all",
            ]

          [32m+[0m[0m applications {
              [32m+[0m[0m excluded_applications = []
              [32m+[0m[0m included_applications = [
                  [32m+[0m[0m "All",
                ]
            }

          [32m+[0m[0m users {
              [32m+[0m[0m excluded_users = []
              [32m+[0m[0m included_users = [
                  [32m+[0m[0m "42ce0cef-7f84-48ca-960d-2d6f91540906",
                ]
            }
        }

      [32m+[0m[0m grant_controls {
          [32m+[0m[0m built_in_controls = [
              [32m+[0m[0m "mfa",
            ]
          [32m+[0m[0m operator          = "OR"
        }
    }

[1m  # azuread_conditional_access_policy.vendor_security_gate[0m will be created
[0m  [32m+[0m[0m resource "azuread_conditional_access_policy" "vendor_security_gate" {
      [32m+[0m[0m display_name = "SEC-CAP-02-Vendor-Security-Gate"
      [32m+[0m[0m id           = (known after apply)
      [32m+[0m[0m state        = "enabled"

      [32m+[0m[0m conditions {
          [32m+[0m[0m client_app_types = [
              [32m+[0m[0m "all",
            ]

          [32m+[0m[0m applications {
              [32m+[0m[0m included_applications = [
                  [32m+[0m[0m "All",
                ]
            }

          [32m+[0m[0m users {
              [32m+[0m[0m included_users = [
                  [32m+[0m[0m "f912896a-bda8-4814-836b-dc2817e12679",
                ]
            }
        }

      [32m+[0m[0m grant_controls {
          [32m+[0m[0m built_in_controls = [
              [32m+[0m[0m "mfa",
            ]
          [32m+[0m[0m operator          = "OR"
        }
    }

[1mPlan:[0m 2 to add, 0 to change, 0 to destroy.
[0m[0m[1mazuread_conditional_access_policy.vendor_security_gate: Creating...[0m[0m
[0m[1mazuread_conditional_access_policy.mfa_for_admins: Creating...[0m[0m
[0m[1mazuread_conditional_access_policy.vendor_security_gate: Creation complete after 3s [id=943d
349e-6dc9-4c3a-9e95-d398fd92bee8][0m
[0m[1mazuread_conditional_access_policy.mfa_for_admins: Creation complete after 3s [id=48181e6b-9
a2d-4840-9712-97401223bfae][0m
[0m[1m[32m
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
[0m

PS C:\Identity-Lab-Terraform> Get-Content -Path "C:\Identity-Lab-Terraform\main.tf"
# 1. GLOBAL VARIABLES
variable "tenant_domain" {
  type        = string
  default     = "scfun.onmicrosoft.com" # <-- Verify and set to JUST your domain name string
  description = "The target primary domain suffix for the Entra ID tenant."
}

# 2. DYNAMIC IDENTITY LOOKUPS (Data Sources)
data "azuread_user" "admin_user" {
  user_principal_name = "alexadmin@${var.tenant_domain}"
}

data "azuread_user" "vendor_user" {
  user_principal_name = "vsupport@${var.tenant_domain}"
}

# 3. ZERO-TRUST POLICY 01: Enforce MFA for Administrative Personas
resource "azuread_conditional_access_policy" "mfa_for_admins" {
  display_name = "SEC-CAP-01-MFA-For-Administrators"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]
    
    applications {
      included_applications = ["All"]
      excluded_applications = []
    }

    users {
      included_users = [data.azuread_user.admin_user.object_id]
      excluded_users = []
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# 4. ZERO-TRUST POLICY 02: Restrict Third-Party Vendor Access Parity
resource "azuread_conditional_access_policy" "vendor_security_gate" {
  display_name = "SEC-CAP-02-Vendor-Security-Gate"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users = [data.azuread_user.vendor_user.object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}
