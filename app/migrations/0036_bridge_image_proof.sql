-- 0036: Bridge proof build. The image pipeline rendered successfully (real job
-- e6e01a0d, 1 credit, output below) proving the request-to-output loop of the
-- Higgsfield bridge end to end. The video record stays blocked: the video
-- engine refuses with not_enough_credits on the workspace despite image
-- credits being spendable — a video-pool issue, not a bridge issue.
INSERT OR IGNORE INTO build_requests (id, org_id, title, build_type, spec, status, output_url) VALUES
('bld_bridge_image_proof', 'org_zeus_shared', 'Bridge proof build image', 'image',
 'prompt:Simple diagnostic test image, single cyan glowing orb on dark background;engine:seedream_v4_5;aspect:3:4;output_slot:credit-diagnostic',
 'completed', 'https://d8j0ntlcm91z4.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/hf_20260814_133021_e6e01a0d-f092-4316-8048-80e99f4efbf0.png');