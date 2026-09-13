-- 0063: AWS Earnings & Renewal — asset registry row paired with conn_aws.
-- Tracks the AWS spend/earnings guard and its renewal review alongside the
-- live connection so the Commander can audit both in one place.
INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, identifier, status, cost_reference, renewal_date, region, notes) VALUES
('ast_aws_earnings','subscription','AWS Earnings & Renewal','Amazon Web Services','conn_aws','active','AWS cost guard + client billing attribution (eu-west-2)','2027-08-15','eu-west-2','Paired with the connected AWS Connection — annual renewal review, earnings reference for S3/EC2/CloudFront/RDS assets');