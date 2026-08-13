# Olist Analytics Engineering

An end-to-end analytics engineering project on the [Brazilian E-Commerce dataset by
Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — ~100k orders placed
between 2016 and 2018 — modelled with **dbt** on **DuckDB**.

**Status: in development.** The environment and project scaffolding are in place; the
modelling layers are being built. See [`TASKS.md`](TASKS.md) for the full roadmap.

---

## Stack

| Layer | Tool |
| --- | --- |
| Warehouse | DuckDB (single-file, no server) |
| Transformation | dbt-core 1.10 + dbt-duckdb |
| Language | Python 3.12, SQL |
| Planned | GitHub Actions CI, dbt docs on GitHub Pages, Evidence.dev dashboard |

## Prerequisites

- **Python 3.12.** The stack supports 3.10–3.13; **Python 3.14 will not work**, as
  dbt-duckdb has no build for it. 3.12 is what this project is developed against. Check
  what you have with `py --list` on Windows, and install from
  [python.org](https://www.python.org/downloads/) if needed.
- **Git**
- A **Kaggle account**, to download the raw data.

---

## Getting started

### 1. Clone and create the environment

```powershell
git clone https://github.com/dargucpmi/dbt_portfolio.git
cd dbt_portfolio
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r Requirements.txt
```

<details><summary>Git Bash / macOS / Linux</summary>

```bash
git clone https://github.com/dargucpmi/dbt_portfolio.git
cd dbt_portfolio
python3.12 -m venv .venv
source .venv/Scripts/activate      # Windows Git Bash
source .venv/bin/activate          # macOS / Linux
pip install -r Requirements.txt
```
</details>

If PowerShell blocks the activation script, allow it for the current session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Verify the environment — the DuckDB adapter must appear in the plugin list:

```powershell
dbt --version
```

### 2. Get the raw data

The CSVs are **not** in this repository: they total 121 MB, and a warehouse does not
belong in version control. Download them yourself.

1. Open the [dataset page](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
   and click **Download** (Kaggle login required).
2. Extract the archive into a folder named `archive/` at the repository root.

You should end up with exactly nine CSVs:

```
archive/
├── olist_customers_dataset.csv
├── olist_geolocation_dataset.csv
├── olist_order_items_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
├── olist_orders_dataset.csv
├── olist_products_dataset.csv
├── olist_sellers_dataset.csv
└── product_category_name_translation.csv
```

`archive/` is gitignored, so nothing here will be committed.

### 3. Build the warehouse

From the repository root, with the venv active:

```powershell
python load_to_duckdb.py
```

This creates `olist.duckdb` with a `raw` schema and prints a row count per table. The
loader strips the `olist_` prefix and `_dataset` suffix, so
`olist_order_items_dataset.csv` becomes `raw.order_items`. Expect nine tables;
`geolocation` is by far the largest.

### 4. Run dbt

**Run dbt from inside `olist_dbt/`.** `profiles.yml` lives there and points at
`../olist.duckdb` by relative path, so dbt will not resolve the connection from anywhere
else. There is no `~/.dbt/` setup step — the profile is committed.

```powershell
cd olist_dbt
dbt debug        # all checks should pass
dbt deps         # once packages.yml exists
dbt build        # run models + tests
```

If `dbt debug` passes, you are set up. Open [`TASKS.md`](TASKS.md) and start at phase 0.

---

## Common commands

All of these run from `olist_dbt/`:

```powershell
dbt build                          # run + test everything
dbt build --select stg_orders+     # a model and everything downstream
dbt run --select marts             # one folder
dbt test                           # tests only
dbt source freshness               # source freshness checks
dbt docs generate; dbt docs serve  # browse the lineage graph
dbt compile --select my_model      # inspect generated SQL when debugging
```

Reload the raw data from CSV (from the repository root):

```powershell
python load_to_duckdb.py
```

Explore the warehouse interactively in a browser:

```powershell
python ui.py
```

> **DuckDB allows one writer at a time.** If dbt fails with a lock error, another process
> holds the file — usually `ui.py`, an open DuckDB CLI, or a VS Code extension. Close it
> and retry.

---

## Project structure

```
dbt_portfolio/
├── README.md              # you are here
├── CLAUDE.md              # conventions, environment, dataset pitfalls
├── TASKS.md               # the build roadmap
├── Requirements.txt       # pinned Python dependencies
├── load_to_duckdb.py      # CSV -> DuckDB raw schema
├── ui.py                  # DuckDB web UI launcher
├── archive/               # raw CSVs (gitignored, download yourself)
├── olist.duckdb           # the warehouse (gitignored, built locally)
└── olist_dbt/             # the dbt project
    ├── dbt_project.yml
    ├── profiles.yml       # committed; points at ../olist.duckdb
    ├── models/
    │   ├── staging/       # 1:1 with sources — rename, cast, clean
    │   ├── intermediate/  # joins and fan-out resolution
    │   └── marts/         # dimensional model for BI
    ├── macros/
    ├── seeds/
    ├── snapshots/
    └── tests/
```

## About the data

Nine tables covering orders, order items, payments, reviews, customers, sellers, products,
geolocation, and a Portuguese-to-English category lookup.

It is a deliberately awkward dataset, which is what makes it worth modelling. A few of the
traps handled in this project:

- `customers.customer_id` is **one row per order**, not per person —
  `customer_unique_id` is the actual customer. Retention analysis built on the wrong one
  is silently incorrect.
- `order_payments` has multiple rows per order (installments, vouchers), so joining it to
  order items without aggregating first inflates revenue.
- `order_reviews.review_id` is not unique, and `geolocation` has many noisy rows per zip
  code prefix.

The full list, with how each is handled, is in [`CLAUDE.md`](CLAUDE.md).

## Roadmap

[`TASKS.md`](TASKS.md) — nine phases from environment setup through testing, dimensional
modelling, incremental models and snapshots, governance, CI/CD, and a published dashboard.
Each task is tagged with the dbt Analytics Engineering Certification domain it exercises.
