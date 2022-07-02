resource "aws_kms_key" "aws_backup_key" {
  description             = "AWS Backup KMS key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_backup_vault_notifications" "test" {
  backup_vault_name   = aws_backup_vault.backup-vault.name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_SUCCESSFUL", "BACKUP_JOB_FAILED"]
}

resource "aws_backup_vault" "backup-vault" {
  name        = var.backup_vault_name
  kms_key_arn = aws_kms_key.aws_backup_key.arn
  tags = {
    Role = "backup-vault"
  }
}

resource "aws_backup_plan" "backup-plan" {
  name = "${var.backup_vault_name}_plan"
  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name                = lookup(rule.value, "name", null)
      target_vault_name        = aws_backup_vault.backup-vault.name
      schedule                 = lookup(rule.value, "schedule", null)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", null)
      recovery_point_tags = {
        Frequency  = lookup(rule.value, "name", null)
        Created_By = "aws-backup"
      }
      lifecycle {
        delete_after = lookup(rule.value, "delete_after", null)
      }
    }
  }
}

resource "aws_backup_selection" "backup-selection" {
  iam_role_arn = aws_iam_role.aws-backup-service-role.arn
  name         = "backup_resources"
  plan_id      = aws_backup_plan.backup-plan.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.key
    value = var.value
  }
}


############################################
####### IAM ################################
############################################



data "aws_iam_policy_document" "aws-backup-service-assume-role-policy" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

/* The policies that allow the backup service to take backups and restores */
data "aws_iam_policy" "aws-backup-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "aws-restore-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

data "aws_caller_identity" "current_account" {}

/* Needed to allow the backup service to restore from a snapshot to an EC2 instance
 See https://stackoverflow.com/questions/61802628/aws-backup-missing-permission-iampassrole */
data "aws_iam_policy_document" "example-pass-role-policy-doc" {
  statement {
    sid       = "PassRole"
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:role/*"]
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "aws-backup-service-role" {
  name               = "AWSBackupServiceRole"
  description        = "Allows the AWS Backup Service to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.aws-backup-service-assume-role-policy.json
}

resource "aws_iam_role_policy" "backup-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-backup-service-policy.policy
  role   = aws_iam_role.aws-backup-service-role.name
}

resource "aws_iam_role_policy" "restore-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-restore-service-policy.policy
  role   = aws_iam_role.aws-backup-service-role.name
}

resource "aws_iam_role_policy" "backup-service-pass-role-policy" {
  policy = data.aws_iam_policy_document.example-pass-role-policy-doc.json
  role   = aws_iam_role.aws-backup-service-role.name
}