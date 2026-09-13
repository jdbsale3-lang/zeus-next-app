-- 0053-fixed: ZEUS SEO TEAM — 50 scheduled agents, registered against the LIVE schema.
-- Corrects the malformed continuation (0053) that referenced non-existent tables
-- (scheduled_agent, project_rows) and had mismatched column counts.
-- Table: scheduled_agents (id, org_id, name, prompt, schedule, enabled, max_runs_per_day, email_to)

-- 1) Register the SEO project
INSERT OR IGNORE INTO projects (id, org_id, name, slug, category, status, description)
VALUES ('prj_zeus_seo_50', 'org_zeus_shared', 'ZEUS AI — 50-Agent SEO Team', 'zeus-seo-team-50', 'product', 'live',
'Registered 50-agent SEO stack: research, content, technical, authority, analytics and ops agents that run on schedule.');

-- 2) The 50 SEO agents (research 12, content 10, technical 10, authority 8, analytics 7, ops 3)
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, enabled, max_runs_per_day, email_to) VALUES
-- RESEARCH (12)
('seo_res_keyword', 'org_zeus_shared', 'SEO: Keyword Scout', 'Expand the seed keyword into a scored keyword set (volume, difficulty, opportunity). Plain words, no symbols. Only report what a tool returned.', 'weekly Monday 07:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_competitor', 'org_zeus_shared', 'SEO: Competitor Scout', 'Identify the competitive landscape for the target keyword and predict SERP features in play. Plain words.', 'weekly Monday 07:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_trend', 'org_zeus_shared', 'SEO: Trend Spotter', 'Signal whether the keyword is rising, steady, seasonal or emerging. Plain words, no invented numbers.', 'daily 06:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_longtail', 'org_zeus_shared', 'SEO: Long-Tail Miner', 'Mine long-tail and question-form variants of the target keyword with high intent. Plain words.', 'weekly Monday 07:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_geo', 'org_zeus_shared', 'SEO: Geo Localizer', 'Detect local-search intent and append location modifiers for map and near-me queries. Exact names and addresses only.', 'daily 05:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_season', 'org_zeus_shared', 'SEO: Seasonality Analyst', 'Assign a season bucket to the keyword so publishing windows and refresh cycles align. Plain words.', 'weekly Monday 07:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_cluster', 'org_zeus_shared', 'SEO: Keyword Clusterer', 'Group the keyword and variants into intent-based clusters so one page ranks for a family of queries. Plain words.', 'weekly Monday 07:40', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_intent', 'org_zeus_shared', 'SEO: Search Intent Analyst', 'Classify each keyword as informational, commercial, transactional or navigational. Plain words.', 'weekly Monday 07:50', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_serp', 'org_zeus_shared', 'SEO: SERP Analyzer', 'Predict the SERP features likely to surface (featured snippet, PAA, local pack, image, video, shopping). Plain words.', 'weekly Monday 08:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_gap', 'org_zeus_shared', 'SEO: Content Gap Analyst', 'Score topic coverage against competitors and name the missing subtopics. Plain words.', 'weekly Monday 08:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_compcontent', 'org_zeus_shared', 'SEO: Competitor Content Analyst', 'Extract entities and coverage from competitor reference content so we can out-brief them. Plain words.', 'weekly Monday 08:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_res_journey', 'org_zeus_shared', 'SEO: Buyer Journey Mapper', 'Map the keyword family onto the funnel: awareness, consideration or decision. Plain words.', 'weekly Monday 08:30', 1, 4, 'jdbsale3@gmail.com'),
-- CONTENT (10)
('seo_con_strategist', 'org_zeus_shared', 'SEO: Content Strategist', 'Own the content plan: which clusters to publish, in what order, and what success looks like. Plain words.', 'weekly Monday 09:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_clusterarch', 'org_zeus_shared', 'SEO: Topic Cluster Architect', 'Design the pillar page and supporting cluster pages so internal links compound. Plain words.', 'weekly Monday 09:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_persona', 'org_zeus_shared', 'SEO: Persona Definer', 'Build the reader persona from templates so tone and CTAs match the audience. Plain words.', 'weekly Monday 09:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_ia', 'org_zeus_shared', 'SEO: Information Architect', 'Design the site tree and URL taxonomy so the keyword family lives at the right depth. Plain words.', 'weekly Monday 09:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_links', 'org_zeus_shared', 'SEO: Internal Link Architect', 'Plan internal-link flows so link equity favors the money keyword. List exact anchors and source pages. Plain words.', 'weekly Monday 09:40', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_url', 'org_zeus_shared', 'SEO: URL Structure Architect', 'Derive clean keyword-bearing URL slugs and guard URL conventions. Plain words.', 'weekly Monday 09:50', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_taxonomy', 'org_zeus_shared', 'SEO: Taxonomy Designer', 'Propose category and tag nodes from keyword tokens for navigation and faceting. Plain words.', 'weekly Monday 10:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_calendar', 'org_zeus_shared', 'SEO: Content Calendar Planner', 'Sequence publishing dates and refresh cadence for the keyword plan. Plain words.', 'weekly Monday 10:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_titlemeta', 'org_zeus_shared', 'SEO: Title & Meta Optimizer', 'Draft the page title (max 60 chars) and meta description (max 155) with the keyword front-loaded. Plain words.', 'weekly Monday 10:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_con_heading', 'org_zeus_shared', 'SEO: Heading Structure Optimizer', 'Validate or generate the H1/H2/H3 outline so headings carry the keyword. Plain words.', 'weekly Monday 10:30', 1, 4, 'jdbsale3@gmail.com'),
-- TECHNICAL (10)
('seo_tec_body', 'org_zeus_shared', 'SEO: Body Copy Optimizer', 'Score body copy for keyword presence and readability; flag thin or stuffed sections. Plain words.', 'daily 06:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_image', 'org_zeus_shared', 'SEO: Image Optimizer', 'Check alt text, filenames and entity relevance so images support accessibility and topical relevance. Plain words.', 'daily 06:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_schema', 'org_zeus_shared', 'SEO: Schema Markup Builder', 'Build and validate structured data (Article, FAQ, Product, LocalBusiness) as JSON-LD. Only when real. Plain words.', 'daily 06:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_canonical', 'org_zeus_shared', 'SEO: Canonical Auditor', 'Check the canonical tag is present and self-referencing; flag missing or cross-domain canonicals. Plain words.', 'daily 06:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_readability', 'org_zeus_shared', 'SEO: Readability Optimizer', 'Compute an approximate Flesch score and classify readable, moderate or hard. Plain words.', 'daily 06:40', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_density', 'org_zeus_shared', 'SEO: Keyword Density Optimizer', 'Measure keyword occurrences against word count and issue an under/over-optimization verdict. Plain words.', 'daily 06:50', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_cta', 'org_zeus_shared', 'SEO: CTA & Conversion Optimizer', 'Count CTA phrases and align the call-to-action with the detected intent and funnel stage. Plain words.', 'daily 07:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_snippet', 'org_zeus_shared', 'SEO: Featured Snippet Optimizer', 'Extract a featured-snippet candidate paragraph aligned with the predicted SERP feature. Plain words.', 'daily 07:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_crawl', 'org_zeus_shared', 'SEO: Crawl Analyzer', 'Evaluate crawlability from status codes and blocked flags. Full URL and the diff. Plain words.', 'daily 04:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_index', 'org_zeus_shared', 'SEO: Indexation Auditor', 'Compare indexed pages against the total and flag exclusion gaps. Full URL. Plain words.', 'daily 04:40', 1, 4, 'jdbsale3@gmail.com'),
-- AUTHORITY (8)
('seo_tec_robots', 'org_zeus_shared', 'SEO: robots.txt Specialist', 'Parse robots.txt directive counts and flag over-blocking that hides the target page. Plain words.', 'weekly Tuesday 08:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_sitemap', 'org_zeus_shared', 'SEO: XML Sitemap Engineer', 'Validate the sitemap URL set and confirm target pages are present. Plain words.', 'weekly Tuesday 08:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_speed', 'org_zeus_shared', 'SEO: Page Speed Optimizer', 'Grade Core Web Vitals (LCP, CLS, INP) against good/needs-improvement/poor and prioritize fixes. Plain words.', 'weekly Tuesday 08:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_mobile', 'org_zeus_shared', 'SEO: Mobile Usability Auditor', 'Run the mobile usability checklist: viewport, tap targets, font size, no horizontal scroll. Plain words.', 'weekly Tuesday 08:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_hreflang', 'org_zeus_shared', 'SEO: Hreflang Specialist', 'Validate hreflang tags for missing x-default and duplicates. Plain words.', 'weekly Tuesday 08:40', 1, 4, 'jdbsale3@gmail.com'),
('seo_tec_redirect', 'org_zeus_shared', 'SEO: Redirect Mapper', 'Classify the redirect map by status code and flag self-loops and chains. Full URL. Plain words.', 'weekly Tuesday 08:50', 1, 4, 'jdbsale3@gmail.com'),
('seo_aut_linkbuild', 'org_zeus_shared', 'SEO: Link Building Strategist', 'Plan backlink acquisition tactics: data studies, expert roundups, broken-link outreach, digital assets. Plain words.', 'weekly Wednesday 09:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_aut_pr', 'org_zeus_shared', 'SEO: Digital PR Architect', 'Craft the PR angle and target-list strategy that earns editorial links. Plain words.', 'weekly Wednesday 09:10', 1, 4, 'jdbsale3@gmail.com'),
-- ANALYTICS (7)
('seo_aut_outreach', 'org_zeus_shared', 'SEO: Outreach Copywriter', 'Write the outreach subject line and body template personalized around the keyword. Plain words.', 'weekly Wednesday 09:20', 1, 4, 'jdbsale3@gmail.com'),
('seo_aut_anchor', 'org_zeus_shared', 'SEO: Anchor Text Optimizer', 'Audit the anchor profile for exact-match overuse and recommend a natural mix. Plain words.', 'weekly Wednesday 09:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_aut_mentions', 'org_zeus_shared', 'SEO: Brand Mention Tracker', 'Track unlinked brand mentions and link-share signals so outreach converts mentions into links. Plain words.', 'daily 11:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_ana_kpi', 'org_zeus_shared', 'SEO: KPI Dashboard Builder', 'Roll up the KPI set (views, clicks, impressions, CTR, avg position) into a single scorecard. Plain words.', 'weekly Friday 09:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_ana_rank', 'org_zeus_shared', 'SEO: Rank Tracker Analyst', 'Track current vs target position and compute the delta over rank history. Plain words.', 'daily 08:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_ana_refresh', 'org_zeus_shared', 'SEO: Content Refresh Analyst', 'Flag stale content (180+ days) that needs a refresh to reclaim rankings. Plain words.', 'weekly Friday 09:10', 1, 4, 'jdbsale3@gmail.com'),
('seo_ana_quality', 'org_zeus_shared', 'SEO: Quality Gate', 'Final QA: verify title, meta, headings, keyword presence, links, schema and images before a page ships. Plain words.', 'weekly Friday 09:20', 1, 4, 'jdbsale3@gmail.com'),
-- OPS (3)
('seo_ops_orchestrator', 'org_zeus_shared', 'SEO: Team Orchestrator', 'Receive the SEO job, validate context, dispatch per the pipeline and manage retries and budget. Plain words.', 'daily 07:30', 1, 4, 'jdbsale3@gmail.com'),
('seo_ops_publisher', 'org_zeus_shared', 'SEO: Publisher', 'Publish approved artifacts to the CMS, set metadata and submit the sitemap. Plain words.', 'daily 18:00', 1, 4, 'jdbsale3@gmail.com'),
('seo_ops_compliance', 'org_zeus_shared', 'SEO: Compliance Reviewer', 'Enforce YMYL safety, spam policy and data privacy in all outputs. Plain words.', 'daily 19:00', 1, 4, 'jdbsale3@gmail.com');
