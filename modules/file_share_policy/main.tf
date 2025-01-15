
resource "azurerm_backup_policy_file_share" "this" {
  name                = var.file_share_backup_policy.name
  recovery_vault_name = var.recovery_vault_name
  resource_group_name = var.resource_group_name
  timezone            = var.file_share_backup_policy.timezone

  backup {
    frequency = var.file_share_backup_policy.frequency != null ? regex("^Hourly|Daily$", var.file_share_backup_policy.frequency) : null
    time      = var.file_share_backup_policy.frequency == "Daily" && var.file_share_backup_policy["backup"].time != null ? var.file_share_backup_policy["backup"].time : null

    dynamic "hourly" {
      for_each = var.file_share_backup_policy.frequency == "Hourly" ? var.file_share_backup_policy.backup.hourly : {}

      content {
        interval        = var.file_share_backup_policy.frequency == "Hourly" && var.file_share_backup_policy.backup.hourly.interval != null ? var.file_share_backup_policy.backup.hourly.interval : null
        start_time      = var.file_share_backup_policy.frequency == "Hourly" && var.file_share_backup_policy.backup.hourly.interval != null ? var.file_share_backup_policy.backup.hourly.start_time : null
        window_duration = var.file_share_backup_policy.frequency == "Hourly" && var.file_share_backup_policy.backup.hourly.interval != null ? var.file_share_backup_policy.backup.hourly.window_duration : null
      }
    }
  }
  dynamic "retention_daily" {
    for_each = can(regex("^(?:[1-9][0-9]?|1[0-9]{2}|200)$", var.file_share_backup_policy["retention_daily"])) ? { this = var.file_share_backup_policy["retention_daily"] } : {}

    content {
      count = regex("^(?:[1-9][0-9]?|1[0-9]{2}|200)$", var.file_share_backup_policy["retention_daily"])
    }
  }
  dynamic "retention_monthly" {
    for_each = var.file_share_backup_policy["retention_monthly"].count > 0 ? { this = var.file_share_backup_policy["retention_monthly"] } : {}

    content {
      count             = var.file_share_backup_policy["retention_monthly"].count != 0 ? var.file_share_backup_policy["retention_monthly"].count : null
      days              = var.file_share_backup_policy["retention_monthly"].count != 0 && (length(var.file_share_backup_policy["retention_monthly"].weekdays) == 0 || length(var.file_share_backup_policy["retention_monthly"].weekdays) == 0) ? var.file_share_backup_policy["retention_monthly"].days : null
      include_last_days = var.file_share_backup_policy["retention_monthly"].count != 0 && (length(var.file_share_backup_policy["retention_monthly"].weekdays) == 0 || length(var.file_share_backup_policy["retention_monthly"].weekdays) == 0) ? var.file_share_backup_policy["retention_monthly"].include_last_days != null ? var.file_share_backup_policy["retention_monthly"].include_last_days : null : null
      weekdays          = var.file_share_backup_policy["retention_monthly"].count != 0 && (length(var.file_share_backup_policy["retention_monthly"].days) == 0 || var.file_share_backup_policy["retention_monthly"].include_last_days != null) ? length(var.file_share_backup_policy["retention_monthly"].weekdays) != 0 ? var.file_share_backup_policy["retention_monthly"].weekdays : null : null
      weeks             = var.file_share_backup_policy["retention_monthly"].count != 0 && (length(var.file_share_backup_policy["retention_monthly"].days) == 0 || var.file_share_backup_policy["retention_monthly"].include_last_days != null) ? length(var.file_share_backup_policy["retention_monthly"].weeks) != 0 ? var.file_share_backup_policy["retention_monthly"].weeks : null : null
    }
  }
  dynamic "retention_weekly" {
    for_each = var.file_share_backup_policy["retention_weekly"].count > 0 && length(var.file_share_backup_policy["retention_weekly"].weekdays) > 0 ? { this = var.file_share_backup_policy["retention_weekly"] } : {}

    content {
      count    = var.file_share_backup_policy["retention_weekly"].count != 0 ? var.file_share_backup_policy["retention_weekly"].count : null
      weekdays = var.file_share_backup_policy["retention_weekly"].count != 0 && length(var.file_share_backup_policy["retention_weekly"].weekdays) > 0 ? var.file_share_backup_policy["retention_weekly"].weekdays : null
    }
  }
  dynamic "retention_yearly" {
    for_each = var.file_share_backup_policy["retention_yearly"].count > 0 ? { this = var.file_share_backup_policy["retention_yearly"] } : {}

    content {
      count             = var.file_share_backup_policy["retention_yearly"].count != 0 && var.file_share_backup_policy["retention_yearly"].count != 0 ? var.file_share_backup_policy["retention_yearly"].count : null
      months            = var.file_share_backup_policy["retention_yearly"].count != 0 && (var.file_share_backup_policy["retention_yearly"].count != 0 && length(var.file_share_backup_policy["retention_yearly"].months) > 0) ? var.file_share_backup_policy["retention_yearly"].months : []
      days              = var.file_share_backup_policy["retention_yearly"].count != 0 && (length(var.file_share_backup_policy["retention_yearly"].weekdays) == 0 || length(var.file_share_backup_policy["retention_yearly"].weekdays) == 0) ? var.file_share_backup_policy["retention_yearly"].days : null
      include_last_days = var.file_share_backup_policy["retention_yearly"].count != 0 && (length(var.file_share_backup_policy["retention_yearly"].weekdays) == 0 || length(var.file_share_backup_policy["retention_yearly"].weekdays) == 0) ? var.file_share_backup_policy["retention_yearly"].include_last_days != null ? var.file_share_backup_policy["retention_yearly"].include_last_days : null : null
      weekdays          = var.file_share_backup_policy["retention_yearly"].count != 0 && (length(var.file_share_backup_policy["retention_yearly"].days) == 0 || var.file_share_backup_policy["retention_yearly"].include_last_days != null) ? length(var.file_share_backup_policy["retention_yearly"].weekdays) != 0 ? var.file_share_backup_policy["retention_yearly"].weekdays : null : null
      weeks             = var.file_share_backup_policy["retention_yearly"].count != 0 && (length(var.file_share_backup_policy["retention_yearly"].days) == 0 || var.file_share_backup_policy["retention_yearly"].include_last_days != null) ? length(var.file_share_backup_policy["retention_yearly"].weeks) != 0 ? var.file_share_backup_policy["retention_yearly"].weeks : null : null
    }
  }
}
