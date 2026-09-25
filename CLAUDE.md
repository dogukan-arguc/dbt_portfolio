# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this project is

A portfolio-grade dbt project on the **Olist Brazilian E-Commerce** dataset, running on
**DuckDB**. Two goals, in priority order:

1. **Portfolio piece.** It must survive being opened by a hiring manager: clean DAG, real
   tests, CI that goes green, published docs, a live dashboard. "It runs on my machine"
   is a failure state.
2. **dbt Analytics Engineering Certification prep.** Every phase in `TASKS.md` is tagged
   with the exam domain it exercises. The project is the study method.

The owner completed *The Complete dbt Bootcamp: Zero to Hero* (Zoltan C. Toth / Nordquant)
and is now building this to consolidate and go beyond it.

## The single most important rule

**The owner implements every model, test, macro, and config himself. Do not write the
implementation for him.**

This project exists to build skill, not to produce files. Handing over finished SQL
defeats the entire point.

| Claude should | Claude should not |
| --- | --- |
| Explain a concept, materialization, or error message | Write the model SQL and hand it over |
| Point at the right docs page or dbt feature | Silently scaffold files that are on the roadmap |
| Review code that is already written, and push back honestly | Rewrite working code to "improve" it uninvited |
| Give a graduated hint when asked (nudge → approach → code) | Jump straight to the answer |
| Debug a failing `dbt build` alongside him | "Fix" it by rewriting the model from scratch |
| Run read-only inspection (`dbt ls`, `dbt compile`, DuckDB queries) | Run `dbt run`/`dbt build` unprompted |

**Exception:** if he explicitly says "write it", "yaz", "implement this one", or "give me
the code" — then write it, fully and well. An explicit request overrides this rule; do not
withhold and do not lecture about learning.

**Hint protocol.** When he asks for a hint, start at the smallest useful level and stop
there. Escalate only when he asks again.

- **L1 — Nudge:** which concept or dbt feature applies, nothing more.
- **L2 — Approach:** the shape of the solution in prose (which CTEs, which join grain).
- **L3 — Skeleton:** structure with the hard parts left as `-- TODO`.
- **L4 — Full code:** only on explicit request.

## Language

**All committed artifacts are in English** — model names, column names, code comments,
`description:` fields, `README.md`, dbt docs, commit messages, `TASKS.md`. The repo is
read internationally.

The one exception is `TASKS.tr.md`, a section-by-section Turkish mirror of the roadmap.
It carries no checkboxes: progress lives in `TASKS.md` alone, so the two files can never
disagree about what is done. Edit both when a task's wording changes.

Chat conversation with the owner is in **Turkish**.

## Environment

**uv manages this project.** Do not use `pip`, `python -m venv`, or the global Python
directly — the global 3.14 install has `dbt-snowflake` and no DuckDB adapter, and would
mislead any check run against it.

- Dependencies are declared in `pyproject.toml` and resolved in **`uv.lock`, which is
  committed**. `uv sync` reproduces the environment exactly; never hand-edit the lock.
- **Python 3.12**, pinned by `.python-version` and fetched by uv on demand. The stack
  supports 3.10–3.13; 3.14 has no dbt-duckdb build.
- Pinned: `dbt-core~=1.10.22`, `dbt-duckdb~=1.10.1`, `duckdb~=1.5.0`. dbt-core 1.10 is
  the version the certification targets — do not bump to 1.11/1.12 without a deliberate
  decision.
- **Node v24** is installed, for the Evidence.dev BI layer in phase 7.

```bash
uv sync                   # create/refresh .venv from the lock
uv run dbt --version      # run a command without activating
uv add <package>          # add a dependency and update the lock
```

`uv run` resolves the project from any subdirectory, so it works from `olist_dbt/`
without activation. Prefix Python and dbt invocations with `uv run` unless the
environment is known to be active.

### Working from another machine

A fresh clone is code only — no `olist_dbt/data/`, no `olist.duckdb`, no `.venv/`.
Nothing machine-specific is committed, so the sequence is always:

1. Install uv, clone the repo, run `uv sync`. Python itself comes from uv — there is no
   separate interpreter install step.
2. `cd olist_dbt`, then `uv run dbt deps` and `uv run dbt debug`.
3. `uv run dbt seed && uv run dbt build`. The committed seeds are meant to carry this on
   their own — no CSV download, no loader (task `0.5`).

For the full ~100k-order dataset, add the raw-CSV step before building. Both scripts
resolve `data/raw` and `olist.duckdb` relative to the **current directory**, so they must
be run from inside `olist_dbt/`, not from the repo root:

```bash
cd olist_dbt
uv run python ../scripts/get_data.py        # Kaggle -> data/raw, then loads it
uv run python ../scripts/load_to_duckdb.py  # data/raw -> raw.* in olist.duckdb
```

`profiles.yml` is committed, so there is no `~/.dbt/` setup step. Neither the raw CSVs nor
`olist.duckdb` ever travels through git — the warehouse is rebuilt from source data on
every machine, which is the point of the project.

## Commands

Run dbt from **inside `olist_dbt/`** — `profiles.yml` lives there (not in `~/.dbt/`) and
points at `./olist.duckdb`: the warehouse sits next to it, inside `olist_dbt/`. Running
from the repo root will not resolve.

```bash
cd olist_dbt
uv run dbt debug              # verify connection first when anything looks wrong
uv run dbt deps               # after touching packages.yml
uv run dbt build              # run + test, the default working loop
uv run dbt build --select stg_orders+     # a model and everything downstream
uv run dbt test --select source:olist     # source freshness / source tests
uv run dbt docs generate      # then: uv run dbt docs serve
```

Reload raw data from CSV (**from inside `olist_dbt/`** — the paths inside the script are
relative to the working directory, not to the script file):

```bash
cd olist_dbt
uv run python ../scripts/load_to_duckdb.py
```

**DuckDB single-writer lock:** DuckDB allows one writer at a time. If `dbt` fails with a
lock error, something else holds the file — the `ui.py` process, an open DuckDB CLI, or a
VS Code extension. Close it. For read-only inspection always connect with
`duckdb.connect('olist.duckdb', read_only=True)` so you never block a `dbt build`.

## Repository layout

```
dbt_portfolio/
├── CLAUDE.md              # this file
├── TASKS.md               # the roadmap — the owner's working document
├── TASKS.tr.md            # Turkish mirror of the roadmap — no checkboxes
├── README.md              # setup guide; becomes the portfolio front door in phase 8
├── pyproject.toml         # dependency declarations
├── uv.lock                # resolved versions — committed
├── .python-version        # 3.12
├── scripts/
│   ├── get_data.py        # Kaggle download -> data/raw, then calls the loader
│   ├── load_to_duckdb.py  # CSV -> raw schema loader
│   └── ui.py              # DuckDB web UI launcher (holds a write lock!)
└── olist_dbt/             # the dbt project — run every dbt command from here
    ├── dbt_project.yml
    ├── profiles.yml       # in-repo, points at ./olist.duckdb
    ├── packages.yml       # + package-lock.yml, both committed
    ├── olist.duckdb       # the warehouse, 52 MB — GITIGNORED
    ├── data/raw/          # 9 Kaggle CSVs, 121 MB — GITIGNORED
    ├── models/
    │   ├── staging/
    │   ├── intermediate/
    │   └── marts/
    ├── macros/
    │   └── generate_schema_name.sql
    ├── seeds/             # COMMITTED — see "Two CSV sets" below
    │   ├── product_category_name_translation.csv
    │   └── sample/        # referentially consistent subset (task 0.5)
    ├── snapshots/
    └── tests/
```

## Data

Source: [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
~100k orders, 2016-09 to 2018-10. `scripts/load_to_duckdb.py` strips the `olist_` prefix
and `_dataset` suffix, so `olist_dbt/data/raw/olist_order_items_dataset.csv` lands as
`raw.order_items`.

Nine tables in schema `raw`: `orders`, `order_items`, `order_payments`, `order_reviews`,
`customers`, `sellers`, `products`, `geolocation`, `product_category_name_translation`.

### Two CSV sets — do not confuse them

The repo holds CSVs in two places, and they serve opposite purposes.

| | `olist_dbt/data/raw/` | `olist_dbt/seeds/` |
| --- | --- | --- |
| In git | no — gitignored, 121 MB | **yes, committed** |
| Loaded by | `scripts/load_to_duckdb.py` | `dbt seed` |
| Lands in | schema `raw`, reached via `source()` | target schema / `sample`, reached via `ref()` |
| Contents | the full nine Kaggle files | `product_category_name_translation.csv`, plus eight files under `sample/` |
| Purpose | local development against real volume | a clone that builds with zero setup, and CI where the CSVs are unavailable |

`seeds/product_category_name_translation.csv` sits at the seed root, so it builds into the
target schema. The eight files under `seeds/sample/` pick up `+schema: sample` from
`dbt_project.yml` and hold ~5k orders with their child rows kept referentially consistent.

Two consequences worth knowing before touching either:

- The category translation exists **twice** — as a seed and as
  `raw.product_category_name_translation`. Staging currently reads the source, not the seed.
- There is no switch yet between seeds and `raw`: sources point at `raw` unconditionally,
  so nothing `ref`s the sample seeds. That switch is what a CSV-less clone needs in order
  to build.

### Traps in this dataset — do not let these slide

These are the reason the dataset is good for a portfolio. Each one is a real modeling
decision, and each is worth a `description:` in YAML explaining how it was handled.

- **`customers.customer_id` is not a customer.** It is one row per *order*.
  `customer_unique_id` is the real person. Any "repeat customer" or retention analysis
  built on `customer_id` is silently wrong.
- **`order_items` grain is `(order_id, order_item_id)`**, not `order_id`. Needs a
  surrogate key.
- **`order_payments` fans out** — installments and vouchers give multiple rows per order.
  Joining payments to items without aggregating first inflates revenue. Classic fan-out
  trap; it belongs in an intermediate model.
- **`order_reviews.review_id` is not unique.** The same review can appear against more
  than one order. Decide on a dedup rule and document it.
- **`geolocation` has many rows per `zip_code_prefix`** with noisy lat/lng, plus
  inconsistent city spellings and accents. Needs aggregation, not a naive join.
- **Delivery timestamps are nullable** for cancelled and unavailable orders. Any
  `delivered_customer_date - estimated_delivery_date` metric must state its denominator.
- **`products` has null category names** for a few hundred rows, and categories are in
  Portuguese — `product_category_name_translation` is the lookup.

## Conventions

**Layers.** `staging` → `intermediate` → `marts`. Staging is 1:1 with a source table:
rename, cast, light cleaning, no joins, no business logic. Intermediate holds the joins
and fan-out resolution. Marts are the dimensional model consumed by BI.

**Naming.** `stg_<source>__<entity>`, `int_<entity>_<verb>`, `dim_<entity>`,
`fct_<event>`. YAML files as `_<name>__models.yml`, `_<source>__sources.yml`.

**Materialization.** Staging = view, marts = table (already set in `dbt_project.yml`).
Override per model only with a reason stated in a comment.

**Style.** CTEs over subqueries; an `import` CTE per ref at the top; lowercase SQL
keywords; trailing commas; one column per line; explicit column lists, never `select *`
outside a staging import CTE.

**Schema names.** `macros/generate_schema_name.sql` overrides dbt's default, so a
`+schema: marts` config produces the schema `marts`, not `main_marts`. This is
intentional — do not "fix" it.

**Sources.** `_olist__sources.yml` sets `database: olist` because DuckDB derives the
catalog name from the filename `olist.duckdb`. All nine tables are declared.

## Working agreements

- **Never commit or push unless asked.** The owner drives git.
- **Never commit `olist_dbt/data/`, `olist.duckdb`, `target/`, `dbt_packages/`, `logs/`,
  `.user.yml`, or `.venv/`.** `geolocation` alone is 61 MB, and a database binary in git is
  a visible negative signal in an analytics engineering portfolio. The seeds under
  `olist_dbt/seeds/` are the deliberate exception — they are committed on purpose.

  History was rewritten on 2026-08-13 to purge exactly these: a committed `.venv/` (7,941
  objects, including a 37 MB DuckDB binary) plus the raw CSVs and `olist.duckdb`, taking
  the repo from 125 MB to 23 KB. Note that `.gitignore` does **not** untrack a file that
  is already tracked — that is how they got in despite matching rules. Anyone holding a
  clone from before that date must re-clone.
- Before proposing a change to an existing model, read the model **and** its YAML.
- When something fails, report the actual error output. Do not summarize a failure as a
  success or skip a step quietly.
- `TASKS.md` is the source of truth for scope and sequencing. When a task is finished,
  the owner ticks the box — offer to, but do not tick it for him.
- **Never round-trip a Markdown file through a WYSIWYG or preview-based editor.** Commit
  `8aec9e8` did exactly that to `TASKS.md`: hard wraps collapsed into single 1,200-character
  lines, `**bold**` and backticks inside the raw-HTML blocks were stripped, 14 nested
  `<details>` toggles were flattened into the surrounding paragraph, and the newlines they
  were joined at lost their spaces. Edit these files as plain text only.
