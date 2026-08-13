# Roadmap — Olist Analytics Engineering Project

The build plan for this project. **You implement every task yourself.** Each task states a
goal and a *definition of done* — not a solution. Hints are collapsed; open one only after
you've been stuck for a while. For deeper help, ask Claude and say what hint level you
want (nudge → approach → skeleton → code).

**Cert tags** map each task to a dbt Analytics Engineering Certification exam domain:
`[DEV]` developing models · `[DEBUG]` debugging · `[TEST]` testing · `[MONITOR]`
monitoring · `[DEPLOY]` deploying jobs · `[STATE]` dbt state · `[GOV]` governance.
Verify the domain list against the current official study guide before you sit the exam —
dbt Labs revises it.

**Marked ⭐ = the differentiators.** Most portfolio dbt projects stop after phase 3. These
are what make a hiring manager stop scrolling.

---

## Phase 0 — Foundations

Goal: a clone-and-run repo on a clean, pinned environment.

- [x] **0.1 Set up the environment with uv** `[DEV]`

  `pyproject.toml` declares the dependencies, `.python-version` pins Python 3.12, and
  `uv.lock` is committed. `uv sync` builds `.venv/` from the lock, fetching the
  interpreter if needed.

  *Done when:* `uv run dbt --version` reports dbt-core 1.10.x with the duckdb adapter
  listed. ✅ dbt-core 1.10.23, duckdb 1.10.1.

- [x] **0.2 Verify the connection** `[DEBUG]`

  Run `uv run dbt debug` from inside `olist_dbt/`. Understand *why* it must be run from
  there. ✅ All checks passed.

  *Done when:* all checks pass, and you can explain in one sentence how dbt located
  `profiles.yml` and the DuckDB file.

  <details><summary>Hint</summary>

  dbt looks for `profiles.yml` in the current directory before `~/.dbt/`. The `path:` in
  it is relative to that same directory.
  </details>

- [ ] **0.3 Repo hygiene** `[DEV]`

  Decide the final top-level structure. `logs/` and a stray root-level `logs/dbt.log`
  exist outside the dbt project — clean up. Move `load_to_duckdb.py` and `ui.py` into a
  `scripts/` folder if you prefer a tidier root (update paths if you do).

  *Done when:* `git status` is clean and nothing gitignored is tracked.

- [ ] **0.4 Make data acquisition reproducible** `[DEV]`

  `archive/` is gitignored, so a fresh clone has no data. Write `scripts/get_data.py`
  (or document the manual steps) that pulls the Kaggle dataset into `archive/`, then
  chain it with `load_to_duckdb.py`.

  *Done when:* a stranger with a Kaggle account can go from `git clone` to a populated
  `olist.duckdb` by following the README.

  <details><summary>Hint</summary>

  The `kaggle` CLI (`uv add kaggle`) reads credentials from `~/.kaggle/kaggle.json`.
  The dataset slug is `olistbr/brazilian-ecommerce`. Add the credential path to the README
  prerequisites — never commit the token.
  </details>

- [ ] **0.5 Commit a sample dataset as seeds** ⭐ `[DEV]`

  The full CSVs can't be committed (121 MB, `geolocation` alone is 61 MB). Instead commit
  a **referentially consistent ~1% sample** under `olist_dbt/seeds/` so anyone can
  `dbt build` immediately with zero setup.

  Referentially consistent is the hard part: you can't sample each table independently or
  your joins will produce empty results.

  *Done when:* on a machine with no `archive/` folder, `dbt seed && dbt build` completes
  and marts contain non-trivial rows.

  <details><summary>Hint</summary>

  Sample **orders** first, then take only the child rows belonging to those order ids, and
  only the customers/products/sellers referenced by those children. Sample downward
  through the foreign keys, never sideways.

  <details><summary>More</summary>

  Write `scripts/make_sample.py` using DuckDB: pick ~1000 order ids with
  `USING SAMPLE`, materialize them into a temp table, then `SEMI JOIN` every other table
  against it. Export with `COPY (...) TO 'seeds/x.csv' (HEADER)`. Skip `geolocation` or
  sample it by the zip prefixes that actually survive.

  Then decide how models select between seeds and `raw` — a `target.name` check or a dbt
  var like `{{ var('use_seeds', false) }}` in your source definitions.
  </details>
  </details>

- [ ] **0.6 Add packages** `[DEV]`

  Create `packages.yml` with `dbt_utils`, `dbt_expectations`, `codegen`, and `dbt_date`.
  Run `uv run dbt deps`. Confirm `dbt_packages/` is gitignored but `package-lock.yml` is
  **committed** — the same reasoning as `uv.lock`, one layer down.

  *Done when:* `dbt deps` succeeds and you know what each package is for.

  <details><summary>Hint</summary>

  `codegen` is a time saver you'll use in 1.3 — `dbt run-operation generate_base_model`
  writes a staging model's boilerplate for you from a source. That's scaffolding, not
  the thinking, so using it is fair game.
  </details>

---

## Phase 1 — Sources & Staging

Goal: every raw table declared, documented, and cleanly staged.

- [ ] **1.1 Declare all nine sources** `[DEV]`

  `_olist__sources.yml` currently declares only `orders`. Add the other eight with a
  `description:` each. Loader naming: `raw.order_items`, `raw.order_payments`,
  `raw.order_reviews`, `raw.customers`, `raw.sellers`, `raw.products`, `raw.geolocation`,
  `raw.product_category_name_translation`.

  *Done when:* `dbt ls --select source:olist` lists nine sources.

- [ ] **1.2 Source freshness** `[MONITOR]`

  Add `loaded_at_field` and `freshness` thresholds to `orders`. The data is a static
  2018 dump, so freshness will fail loudly — that's the lesson. Decide how to handle it:
  a generous threshold, `filter:`, or an explicit note that freshness is disabled with a
  comment saying why.

  *Done when:* `dbt source freshness` runs and its result is a deliberate outcome you can
  justify, not an accident.

- [ ] **1.3 Build the staging layer** `[DEV]`

  One `stg_olist__<entity>.sql` per source. Rename to snake_case business names, cast
  types, trim strings, standardize casing. **No joins, no aggregation, no business logic.**

  Specific work: `products` columns have Portuguese/misspelled names
  (`product_name_lenght` — the typo is in the source) — fix them here. Timestamps arriving
  as text need casting.

  *Done when:* nine staging models build as views and each is 1:1 with its source.

  <details><summary>Hint</summary>

  Use the two-CTE pattern: a `source` CTE that does nothing but `select * from
  {{ source(...) }}`, then a `renamed` CTE doing all the work. It makes the diff between
  raw and staged obvious to a reviewer.
  </details>

- [ ] **1.4 Handle the category translation** `[DEV]`

  `product_category_name_translation` is 2.6 KB of static lookup data. Argue whether it
  belongs as a source or as a **seed**, then implement your choice.

  *Done when:* English category names are available downstream and your README or model
  description records the reasoning.

- [ ] **1.5 Document the staging layer** `[DEV]`

  `_staging__models.yml` with a `description:` on every model and every column. Use
  `{{ doc(...) }}` blocks in a `.md` file for anything you repeat (e.g. what
  `customer_unique_id` means — you'll explain it more than once).

  *Done when:* `dbt docs generate` shows no undocumented columns in staging.

---

## Phase 2 — Testing & Data Quality

Goal: tests that would actually catch a regression, not decoration.

- [ ] **2.1 Baseline generic tests** `[TEST]`

  `unique` + `not_null` on every primary key, `relationships` on every foreign key,
  `accepted_values` on `order_status` and `payment_type`.

  Expect failures. `order_reviews.review_id` is **not unique**, and some
  `order_items.product_id` values may not resolve. Do not delete the failing test —
  investigate first.

  *Done when:* `dbt test` is green *and* every test you weakened or removed has a comment
  explaining what you found.

- [ ] **2.2 Composite key tests** `[TEST]`

  `order_items` is keyed on `(order_id, order_item_id)` and `order_payments` on
  `(order_id, payment_sequential)`. A single-column `unique` test can't express that.

  *Done when:* both grains are tested.

  <details><summary>Hint</summary>

  `dbt_utils.unique_combination_of_columns`. The alternative — building a surrogate key
  with `dbt_utils.generate_surrogate_key` and testing that — is also valid and more useful
  downstream. Consider doing both.
  </details>

- [ ] **2.3 dbt_expectations tests** `[TEST]`

  Add value-range and distribution tests where they express a real business rule:
  `price > 0`, `review_score` between 1 and 5, `payment_installments` within a sane
  bound, row-count sanity on marts.

  *Done when:* at least six expectation-style tests exist and each maps to a stated rule.

- [ ] **2.4 Write a custom generic test** `[TEST]`

  A test in `tests/generic/` that takes arguments and can be applied from YAML. Good
  candidate: `assert_no_future_dates`, or a positive-value test that permits a documented
  null rate.

  *Done when:* the test lives in YAML on at least two models.

- [ ] **2.5 Singular tests for the real traps** ⭐ `[TEST]`

  These are the tests that prove you understood the data:

  - **Revenue reconciliation** — total `payment_value` per order vs
    `sum(price + freight_value)` from items, within a tolerance. Catches fan-out bugs.
  - **Delivery sanity** — no `delivered_customer_date` earlier than
    `order_purchase_timestamp`.
  - **Fan-out guard** — `fct_orders` row count equals distinct `order_id` count.

  *Done when:* three singular tests exist in `tests/`, and you can explain what production
  bug each would catch.

- [ ] **2.6 Unit tests** ⭐ `[TEST]`

  dbt 1.8+ `unit_tests:` — fixed input rows, asserted output rows, no warehouse data
  needed. Almost no portfolio project has these. Apply to your most logic-heavy model
  (the payment pivot or an RFM bucketing model).

  *Done when:* at least two unit tests run under `dbt test`, including one edge case
  (a null, or an order with zero payments).

  <details><summary>Hint</summary>

  Unit tests go in the model's YAML, not in `tests/`. They need `given:` with `ref`/
  `source` fixtures and an `expect:` block. Run them with
  `dbt test --select test_type:unit`.
  </details>

- [ ] **2.7 Test configuration** `[TEST]` `[MONITOR]`

  Use `severity: warn` where a failure is informational, `error_if`/`warn_if` thresholds
  where a small number of bad rows is tolerable, and `store_failures: true` on the tests
  worth investigating after the fact.

  *Done when:* not every test is a binary error, and the failure tables are queryable.

---

## Phase 3 — Intermediate & Marts

Goal: a dimensional model a BI tool can sit on without further transformation.

- [ ] **3.1 Resolve the payment fan-out** `[DEV]`

  `order_payments` has multiple rows per order. Build an intermediate model at **one row
  per order** carrying total paid, installment count, and a breakdown by payment type.

  *Done when:* the model has exactly one row per `order_id` and a test proves it.

  <details><summary>Hint</summary>

  Aggregate and pivot in one pass — `sum(case when payment_type = 'credit_card' then
  payment_value end)` per type, grouped by order. `dbt_utils.pivot` can generate this from
  the distinct values if you'd rather not hardcode.
  </details>

- [ ] **3.2 Order items enriched** `[DEV]`

  Join items to products (with English categories) and sellers. Stays at line-item grain.

  *Done when:* row count is unchanged from `stg_olist__order_items` — a join that changes
  the row count is a bug.

- [ ] **3.3 `dim_customers`** ⭐ `[DEV]`

  The headline trap. `customer_id` is one row per order; `customer_unique_id` is the
  actual person. Build the dimension at the **person** grain with first/last order date,
  lifetime order count, and lifetime value.

  *Done when:* the row count is materially lower than `stg_olist__customers`, and the
  model description explains the `customer_id` vs `customer_unique_id` distinction.

- [ ] **3.4 `dim_products` and `dim_sellers`** `[DEV]`

  English categories, null category handled explicitly (an `'unknown'` bucket beats a
  null), physical dimensions cleaned.

  *Done when:* both build with full column-level docs.

- [ ] **3.5 `dim_geolocation`** `[DEV]`

  61 MB, many noisy rows per zip prefix, inconsistent accented city names. Reduce to one
  row per `zip_code_prefix` with a representative coordinate and a canonical city name.

  *Done when:* one row per zip prefix, and you can state which centrality measure you
  chose for lat/lng and why.

  <details><summary>Hint</summary>

  The mean is dragged around by geocoding outliers; the median is not. Also decide whether
  to strip accents for the city name and whether that's lossy.
  </details>

- [ ] **3.6 `dim_date`** `[DEV]`

  A date spine covering the dataset's range with the usual calendar attributes, plus
  Brazilian public holidays if you want to go further (holidays visibly move e-commerce
  volume — Black Friday 2017 is dramatic in this data).

  *Done when:* the spine is gapless across the full order date range.

  <details><summary>Hint</summary>

  `dbt_utils.date_spine`, or `dbt_date.get_date_dimension` for a ready-made version.
  Generating your own is the better learning exercise.
  </details>

- [ ] **3.7 `fct_orders`** `[DEV]`

  One row per order. Foreign keys to every dimension, plus measures: item count, product
  revenue, freight, total paid, review score. Add the delivery timing measures —
  approval lag, delivery days, days early/late vs estimate, an on-time flag.

  *Done when:* one row per order, all FKs pass `relationships` tests, and revenue
  reconciles with the phase 2.5 test.

- [ ] **3.8 `fct_order_items`** `[DEV]`

  Line-item grain with a surrogate key. Allocate order-level payment amounts down to the
  line proportionally — and be able to defend the allocation rule.

  *Done when:* allocated amounts sum back to the order total within tolerance.

- [ ] **3.9 Analytical marts** ⭐ `[DEV]`

  This is where you show analytics judgment rather than plumbing. Build at least three:

  - **`mart_customer_rfm`** — recency/frequency/monetary scoring with named segments
    (Champions, At Risk, Hibernating). Note the honest caveat: most Olist customers order
    exactly once, which makes the F dimension nearly degenerate. Saying so is stronger
    than hiding it.
  - **`mart_seller_scorecard`** — per seller: volume, revenue, average review, on-time
    rate, average shipping lag. Rank within category.
  - **`mart_delivery_performance`** — on-time rate by state, category, and month; the
    relationship between delivery delay and review score. (There's a strong real signal
    here — late deliveries tank review scores. That's your headline chart.)
  - **`mart_cohort_retention`** — monthly acquisition cohorts by repeat purchase rate.
  - **`mart_category_monthly`** — the category × month aggregate for trend charts.

  *Done when:* three or more exist, each documented with the question it answers.

---

## Phase 4 — Advanced Materializations & the Ingestion Clock ⭐

Goal: prove you can handle production patterns — not just rebuild everything nightly.
This phase is the biggest single differentiator in the project.

- [ ] **4.1 Build a simulated ingestion clock** ⭐ `[DEV]`

  The problem: Olist is a static 2018 dump, so incremental models and snapshots are
  meaningless theater on it. The fix: `scripts/simulate_load.py --as-of YYYY-MM-DD` that
  loads into `raw` only the records that existed as of that date, and mutates order status
  to what it was then (an order delivered in March is still `shipped` if you're standing
  in February).

  Now you can advance the clock day by day and watch incremental logic and SCD2 history
  actually work.

  *Done when:* running with two different `--as-of` dates produces genuinely different
  `raw.orders` content, including changed statuses.

  <details><summary>Hint</summary>

  Filter rows on `order_purchase_timestamp <= as_of`. For status, walk the timestamp
  columns backwards: if `delivered_customer_date > as_of` then the order wasn't delivered
  yet — fall back to `shipped`, then `approved`, then `created`, based on which timestamps
  have passed. That backwards walk *is* the exercise.
  </details>

- [ ] **4.2 Incremental `fct_order_items`** `[DEV]` `[DEBUG]`

  Convert to `materialized: incremental` with a `unique_key` and an `is_incremental()`
  filter. Test it properly with the clock from 4.1: full refresh at an early date, then
  advance and run incrementally, then compare against a full refresh at the later date.

  *Done when:* incremental output matches full-refresh output exactly, and you've
  understood the `on_schema_change` options.

- [ ] **4.3 Handle late-arriving data** ⭐ `[DEV]`

  A naive `where updated_at > (select max(...) from {{ this }})` silently drops records
  that arrive out of order. Add a lookback window and show that it recovers rows a naive
  filter would lose.

  *Done when:* you can demonstrate the failure case, then the fix.

- [ ] **4.4 Snapshot order status (SCD2)** ⭐ `[DEV]`

  Snapshot `orders` on `order_status` with the `check` strategy. Advance the clock across
  several dates, snapshotting each time, and build the SCD2 history of orders moving
  `created → approved → shipped → delivered`.

  *Done when:* the snapshot table holds multiple versions of the same `order_id` with
  correct `dbt_valid_from` / `dbt_valid_to`.

- [ ] **4.5 Build a status-duration model on the snapshot** `[DEV]`

  Use the SCD2 history to measure how long orders sit in each status — which is a real
  operational metric you *cannot* compute from the static dump. This is the payoff for
  phase 4.

  *Done when:* average duration per status transition is queryable.

- [ ] **4.6 Ephemeral models and a custom macro** `[DEV]`

  Use `materialized: ephemeral` where a model is pure plumbing, and inspect the compiled
  SQL to see it inlined. Write one genuinely reusable macro (a `cents_to_currency`
  rounder, a status-grouping `case` expression) and use it in three or more models.

  *Done when:* `dbt compile` shows the ephemeral model inlined, and the macro is
  documented in `macros/_macros.yml`.

---

## Phase 5 — Governance & Documentation

Goal: the things that separate a course project from a project on a real team.

- [ ] **5.1 Contracts and constraints on marts** ⭐ `[GOV]`

  `contract: {enforced: true}` on your mart models with column types and constraints
  declared. dbt then refuses to build a model whose shape drifted.

  *Done when:* an intentional type change fails the build with a contract error — verify
  it, then revert. Note that DuckDB enforces only some constraint types; document which
  are checked vs informational.

- [ ] **5.2 Model versions** `[GOV]`

  Version a mart (`fct_orders` v1 → v2 with a breaking change), with `latest_version` and
  a `deprecation_date` on v1.

  *Done when:* both versions build, and `ref('fct_orders')` resolves to the version you
  intended.

- [ ] **5.3 Groups and access** `[GOV]`

  Define groups with owners in YAML. Set `access: private` on staging and intermediate,
  `access: public` on marts.

  *Done when:* a deliberate cross-group `ref()` of a private model raises an error.

- [ ] **5.4 Exposures** `[GOV]` `[MONITOR]`

  Declare your Evidence dashboard (phase 7) as an exposure with owner and depends-on.
  This makes downstream impact visible in the DAG — `dbt build --select +exposure:...`
  becomes meaningful.

  *Done when:* the exposure appears in the docs site with its lineage.

- [ ] **5.5 Documentation pass** `[GOV]`

  Doc blocks for anything repeated, a custom `overview.md` for the docs landing page,
  `persist_docs` enabled so descriptions land in the database catalog.

  *Done when:* the docs site opens on your own overview page, not dbt's default.

---

## Phase 6 — Deployment & CI/CD ⭐

Goal: a green badge and a public docs URL. This is the part hiring managers actually
click.

- [ ] **6.1 CI on pull requests** ⭐ `[DEPLOY]`

  A GitHub Actions workflow that on every PR installs the locked environment, seeds the
  sample data from 0.5, and runs `dbt build`. Since DuckDB is a file, CI needs no
  warehouse credentials at all — this project can have genuinely free, fast CI, which most
  portfolio dbt projects cannot.

  *Done when:* a PR shows a green check, and a deliberately broken model turns it red.

  <details><summary>Hint</summary>

  This is exactly why 0.5 matters — without committed seeds, CI has no data.

  Use the `astral-sh/setup-uv` action with `enable-cache: true`, then `uv sync --locked`.
  The `--locked` flag makes CI **fail** if `uv.lock` is out of sync with
  `pyproject.toml`, which is the behaviour you want — it catches a dependency change
  someone forgot to lock. Cache `dbt_packages/` separately.
  </details>

- [ ] **6.2 Slim CI with state comparison** ⭐ `[STATE]` `[DEPLOY]`

  Build only what changed: `dbt build --select state:modified+ --defer --state ./prod-run-artifacts`.
  Requires publishing `manifest.json` from a main-branch run and downloading it in the PR
  job.

  *Done when:* a PR touching one staging model builds that model and its children, not the
  whole project — and the log proves it.

  <details><summary>Hint</summary>

  Store the production `manifest.json` as a GitHub Actions artifact or commit it to a
  dedicated branch. Understanding `state:modified` vs `state:new` vs `result:error`, and
  how `--defer` resolves unbuilt refs, is directly on the exam.
  </details>

- [ ] **6.3 Scheduled production run** `[DEPLOY]` `[MONITOR]`

  A `schedule:` workflow that runs the full build, uploads `manifest.json` and
  `run_results.json` as artifacts, and fails loudly.

  *Done when:* the scheduled run has succeeded at least once unattended.

- [ ] **6.4 Publish dbt docs to GitHub Pages** ⭐ `[DEPLOY]`

  `dbt docs generate` and deploy `target/` to GitHub Pages. **A public, browsable lineage
  DAG is a link you can put directly on your CV** — a reviewer sees your whole model graph
  in ten seconds without cloning anything. Highest impact-per-hour item in this roadmap.

  *Done when:* the docs site is live at a public URL and the lineage graph renders.

  <details><summary>Hint</summary>

  The generated site is static — `index.html` plus `manifest.json` and `catalog.json`.
  Deploy it to a subpath (`/docs/`) so phase 7 can take the site root.
  </details>

- [ ] **6.5 Pipeline monitoring** `[MONITOR]`

  Parse `run_results.json` after each run into a small report: slowest models, test
  failures, total runtime. Optionally load the artifacts back into DuckDB and model them —
  dbt modeling its own metadata is a nice touch.

  *Done when:* a failing run produces a readable summary, not a wall of logs.

---

## Phase 7 — BI Layer ⭐

Goal: a live dashboard URL. **Evidence.dev**, not Streamlit — Evidence reads DuckDB
natively and builds a *static* site, so GitHub Pages hosts it free with no server. Node
v24 is already installed.

- [ ] **7.1 Set up Evidence** `[DEPLOY]`

  Scaffold under `reports/`, point its DuckDB connection at the built warehouse, verify
  it queries your marts. Gitignore Evidence's build output.

  *Done when:* `npm run dev` renders a page fed by a real mart query.

- [ ] **7.2 Build the pages**

  Four pages, each answering a question rather than dumping a table:

  1. **Executive overview** — revenue trend, order volume, AOV, review average.
  2. **Delivery performance** — on-time rate by state (map), and the delay-vs-review-score
     relationship. This is your strongest finding; lead with it.
  3. **Seller scorecard** — searchable ranked table with drill-down.
  4. **Customer cohorts** — retention heatmap and RFM segment breakdown.

  *Done when:* every page reads from a mart, with no business logic in the dashboard
  layer. Transformation belongs in dbt — that's the whole thesis of the project.

- [ ] **7.3 Deploy the dashboard** ⭐ `[DEPLOY]`

  Extend CI to build Evidence and publish it to GitHub Pages at the site root, with dbt
  docs at `/docs/`.

  *Done when:* two public URLs — dashboard and lineage — both refreshed automatically.

---

## Phase 8 — Portfolio Polish

Goal: a stranger understands the project's value in ninety seconds.

- [ ] **8.1 README**

  Structure: one-line pitch → live links (dashboard, docs) → architecture diagram → three
  interesting findings with numbers → the modeling decisions you're proudest of → local
  setup. Put the links **above the fold**, before setup instructions.

  *Done when:* someone who has never used dbt understands what you built and why.

- [ ] **8.2 Architecture diagram**

  A Mermaid diagram in the README: CSV → DuckDB raw → staging → intermediate → marts →
  Evidence, with CI annotated. Mermaid renders natively on GitHub — no image files.

- [ ] **8.3 The interesting findings**

  Three concrete, quantified insights from your marts. "Orders delivered more than N days
  late average a review score of X versus Y for on-time" beats any amount of listed
  tooling. Numbers, not adjectives.

- [ ] **8.4 CV entry**

  Two lines, both with links: what the pipeline does and its scale (model count, test
  count, row count), plus the stack. Let the live docs link carry the proof.

- [ ] **8.5 Certification self-check**

  Walk the coverage table below. Anything unchecked is a gap to close before the exam —
  either in the project or in dedicated study.

---

## Certification coverage

| Domain | Covered by |
| --- | --- |
| **Developing dbt models** | 1.3, 1.4, 3.1–3.9, 4.2, 4.6 — layers, materializations, refs, sources, seeds, macros, Jinja |
| **Debugging data modeling errors** | 0.2, 2.1, 4.2 — `dbt debug`, compiled SQL, logs, fan-out and grain bugs |
| **Implementing dbt tests** | 2.1–2.7 — generic, custom generic, singular, unit, severity, `store_failures` |
| **Monitoring data pipelines** | 1.2, 2.7, 5.4, 6.3, 6.5 — freshness, artifacts, exposures, scheduled runs |
| **Deploying dbt jobs** | 6.1–6.4, 7.3 — CI/CD, environments, scheduling, docs deployment |
| **Understanding dbt state** | 6.2 — `state:modified`, `--defer`, artifacts, slim CI |
| **Understanding governance** | 5.1–5.5 — contracts, versions, groups, access, exposures, docs |

**Weakest coverage:** dbt state. It's the domain most people under-practise because it
needs a real deployment to exercise. Task 6.2 is the only place you'll meet it — don't
skip it.

**Not covered by this project:** dbt Cloud specifics (job UI, IDE, environment variables,
Cloud-only scheduling) and warehouse-specific behavior. Study those separately — the exam
assumes dbt Cloud familiarity that a local DuckDB project can't give you.
