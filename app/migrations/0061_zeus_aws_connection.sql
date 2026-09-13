-- 0061: LIVE CONNECTIONS — AWS account registered.
INSERT OR IGNORE INTO connections (id, org_id, provider, account_label, kind, status, url, note) VALUES
('conn_aws','org_user_3GJd975B4Ec780O9XOw','aws','AWS','api','connected','https://console.aws.amazon.com','Cloud: S3, EC2, CloudFront — ZEUS infra account');