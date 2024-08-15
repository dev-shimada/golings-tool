resource "aws_dynamodb_table" "main" {
  name         = "golings-tool"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "no"
  attribute {
    name = "no"
    type = "N"
  }
}

data "aws_ssm_parameter" "main" {
  name = "/golings-tool/WEBHOOK_URL"
}

resource "aws_ecr_repository" "main" {
  name                 = "golings-tool"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
}
data "aws_ecr_image" "main" {
  repository_name = aws_ecr_repository.main.name
  image_tag       = "latest"
}

resource "aws_iam_role" "main_lambda_invoke_role" {
  name = "golings-tool-lambda-invoke-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSLambdaExecute",
  ]
}

resource "aws_iam_role" "main" {
  name = "golings-tool"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}
resource "aws_iam_policy" "main" {
  name = "golings-tool"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "${aws_dynamodb_table.main.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "${data.aws_ssm_parameter.main.arn}"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_cloudwatch_event_rule" "main" {
  name                = "golings-tool"
  schedule_expression = var.schedule
  role_arn            = aws_iam_role.main_lambda_invoke_role.arn
}
resource "aws_cloudwatch_event_target" "main" {
  target_id = "golings-tool"
  rule      = aws_cloudwatch_event_rule.main.name
  arn       = aws_lambda_function.main.arn
}
resource "aws_lambda_permission" "main" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.main.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/golings-tool"
  retention_in_days = 7
}
resource "aws_lambda_function" "main" {
  function_name = "golings-tool"
  role          = aws_iam_role.main.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.main.repository_url}@${data.aws_ecr_image.main.image_digest}"
  timeout       = 30
  memory_size   = 128
  architectures = ["x86_64"]
  publish       = false
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.main.name
  }
  environment {
    variables = {
      "TABLE_NAME" = "${aws_dynamodb_table.main.name}"
    }
  }
}

resource "aws_dynamodb_table_item" "main_1" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "1"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables1"
    }
    path = {
      S = "exercises/variables/variables1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_2" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "2"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables2"
    }
    path = {
      S = "exercises/variables/variables2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_3" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "3"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables3"
    }
    path = {
      S = "exercises/variables/variables3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_4" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "4"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables4"
    }
    path = {
      S = "exercises/variables/variables4/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_5" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "5"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables5"
    }
    path = {
      S = "exercises/variables/variables5/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_6" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "6"
    }
    notified = {
      S = ""
    }
    name = {
      S = "variables6"
    }
    path = {
      S = "exercises/variables/variables6/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_7" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "7"
    }
    notified = {
      S = ""
    }
    name = {
      S = "functions1"
    }
    path = {
      S = "exercises/functions/functions1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_8" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "8"
    }
    notified = {
      S = ""
    }
    name = {
      S = "functions2"
    }
    path = {
      S = "exercises/functions/functions2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_9" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "9"
    }
    notified = {
      S = ""
    }
    name = {
      S = "functions3"
    }
    path = {
      S = "exercises/functions/functions3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_10" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "10"
    }
    notified = {
      S = ""
    }
    name = {
      S = "functions4"
    }
    path = {
      S = "exercises/functions/functions4/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_11" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "11"
    }
    notified = {
      S = ""
    }
    name = {
      S = "if1"
    }
    path = {
      S = "exercises/if/if1/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_12" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "12"
    }
    notified = {
      S = ""
    }
    name = {
      S = "if2"
    }
    path = {
      S = "exercises/if/if2/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_13" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "13"
    }
    notified = {
      S = ""
    }
    name = {
      S = "switch1"
    }
    path = {
      S = "exercises/switch/switch1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_14" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "14"
    }
    notified = {
      S = ""
    }
    name = {
      S = "switch2"
    }
    path = {
      S = "exercises/switch/switch2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_15" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "15"
    }
    notified = {
      S = ""
    }
    name = {
      S = "switch3"
    }
    path = {
      S = "exercises/switch/switch3/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_16" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "16"
    }
    notified = {
      S = ""
    }
    name = {
      S = "primitive_types1"
    }
    path = {
      S = "exercises/primitive_types/primitive_types1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_17" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "17"
    }
    notified = {
      S = ""
    }
    name = {
      S = "primitive_types2"
    }
    path = {
      S = "exercises/primitive_types/primitive_types2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_18" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "18"
    }
    notified = {
      S = ""
    }
    name = {
      S = "primitive_types3"
    }
    path = {
      S = "exercises/primitive_types/primitive_types3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_19" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "19"
    }
    notified = {
      S = ""
    }
    name = {
      S = "primitive_types4"
    }
    path = {
      S = "exercises/primitive_types/primitive_types4/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_20" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "20"
    }
    notified = {
      S = ""
    }
    name = {
      S = "primitive_types5"
    }
    path = {
      S = "exercises/primitive_types/primitive_types5/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_21" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "21"
    }
    notified = {
      S = ""
    }
    name = {
      S = "arrays1"
    }
    path = {
      S = "exercises/arrays/arrays1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_22" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "22"
    }
    notified = {
      S = ""
    }
    name = {
      S = "arrays2"
    }
    path = {
      S = "exercises/arrays/arrays2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_23" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "23"
    }
    notified = {
      S = ""
    }
    name = {
      S = "slices1"
    }
    path = {
      S = "exercises/slices/slices1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_24" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "24"
    }
    notified = {
      S = ""
    }
    name = {
      S = "slices2"
    }
    path = {
      S = "exercises/slices/slices2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_25" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "25"
    }
    notified = {
      S = ""
    }
    name = {
      S = "slices3"
    }
    path = {
      S = "exercises/slices/slices3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_26" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "26"
    }
    notified = {
      S = ""
    }
    name = {
      S = "slices4"
    }
    path = {
      S = "exercises/slices/slices4/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_27" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "27"
    }
    notified = {
      S = ""
    }
    name = {
      S = "maps1"
    }
    path = {
      S = "exercises/maps/maps1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_28" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "28"
    }
    notified = {
      S = ""
    }
    name = {
      S = "maps2"
    }
    path = {
      S = "exercises/maps/maps2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_29" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "29"
    }
    notified = {
      S = ""
    }
    name = {
      S = "maps3"
    }
    path = {
      S = "exercises/maps/maps3/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_30" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "30"
    }
    notified = {
      S = ""
    }
    name = {
      S = "range1"
    }
    path = {
      S = "exercises/range/range1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_31" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "31"
    }
    notified = {
      S = ""
    }
    name = {
      S = "range2"
    }
    path = {
      S = "exercises/range/range2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_32" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "32"
    }
    notified = {
      S = ""
    }
    name = {
      S = "range3"
    }
    path = {
      S = "exercises/range/range3/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_33" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "33"
    }
    notified = {
      S = ""
    }
    name = {
      S = "structs1"
    }
    path = {
      S = "exercises/structs/structs1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_34" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "34"
    }
    notified = {
      S = ""
    }
    name = {
      S = "structs2"
    }
    path = {
      S = "exercises/structs/structs2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_35" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "35"
    }
    notified = {
      S = ""
    }
    name = {
      S = "structs3"
    }
    path = {
      S = "exercises/structs/structs3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_36" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "36"
    }
    notified = {
      S = ""
    }
    name = {
      S = "anonymous_functions1"
    }
    path = {
      S = "exercises/anonymous_functions/anonymous_functions1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_37" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "37"
    }
    notified = {
      S = ""
    }
    name = {
      S = "anonymous_functions2"
    }
    path = {
      S = "exercises/anonymous_functions/anonymous_functions2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_38" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "38"
    }
    notified = {
      S = ""
    }
    name = {
      S = "anonymous_functions3"
    }
    path = {
      S = "exercises/anonymous_functions/anonymous_functions3/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_39" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "39"
    }
    notified = {
      S = ""
    }
    name = {
      S = "generics1"
    }
    path = {
      S = "exercises/generics/generics1/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_40" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "40"
    }
    notified = {
      S = ""
    }
    name = {
      S = "generics2"
    }
    path = {
      S = "exercises/generics/generics2/main.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_41" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "41"
    }
    notified = {
      S = ""
    }
    name = {
      S = "concurrent1"
    }
    path = {
      S = "exercises/concurrent/concurrent1/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_42" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "42"
    }
    notified = {
      S = ""
    }
    name = {
      S = "concurrent2"
    }
    path = {
      S = "exercises/concurrent/concurrent2/main_test.go"
    }
  })
}
resource "aws_dynamodb_table_item" "main_43" {
  lifecycle {
    ignore_changes = [item]
  }
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key
  item = jsonencode({
    no = {
      N = "43"
    }
    notified = {
      S = ""
    }
    name = {
      S = "concurrent3"
    }
    path = {
      S = "exercises/concurrent/concurrent3/main_test.go"
    }
  })
}
