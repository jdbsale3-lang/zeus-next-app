-- 0062: AWS assets registry — paired with the AWS Connection (conn_aws).
INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, identifier, status, cost_reference, renewal_date, region, notes) VALUES
('ast_aws_account','identity','AWS Account','AWS Console','zeus-aws-account','active','Shared infra budget',NULL,'eu-west-2','Root account behind conn_aws — IAM, budgets, alerts'),
('ast_aws_s3','platform','S3 Storage','Amazon S3','zeus-s3','active','Usage based',NULL,'eu-west-2','Assets / uploads bucket — pairs with conn_aws'),
('ast_aws_cloudfront','platform','CloudFront CDN','AWS CloudFront','zeus-cdn','active','Usage based',NULL,'global','Edge distribution for ZEUS media'),
('ast_aws_ec2','platform','EC2 Instances','Amazon EC2','zeus-vps','active','On-demand',NULL,'eu-west-2','Compute for ZEUS + AEGIS services'),
('ast_aws_rds','platform','RDS Database','Amazon RDS','zeus-rds','active','On-demand',NULL,'eu-west-2','Managed SQL for downstream ZEUS services'),
('ast_aws_route53','platform','Route53 DNS','Amazon Route 53','zeus-dns','active','Per record',NULL,'eu-west-2','DNS for public domains'),
('ast_aws_kms','secret','KMS Keys','AWS KMS','zeus-kms','active','Free tier used','2027-08-15','eu-west-2','Encryption — review rotation annually'),
('ast_aws_budget','subscription','AWS Budget','AWS Billing','zeus-budget','active','Alerts on',NULL,'global','Cost alerts + monthly spend guard');