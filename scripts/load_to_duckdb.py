# load_raw.py
import duckdb
import pathlib

DATA_DIR = pathlib.Path("data/raw")
DB_PATH = "olist.duckdb"

con = duckdb.connect(DB_PATH)
con.sql("CREATE SCHEMA IF NOT EXISTS raw")

for f in sorted(DATA_DIR.glob("*.csv")):
    tbl = f.stem.replace("olist_", "").replace("_dataset", "")
    con.sql(f"""
        CREATE OR REPLACE TABLE raw.{tbl} AS
        SELECT * FROM read_csv(
            '{f.as_posix()}',
            header = true,
            sample_size = -1
        )
    """)
    n = con.sql(f"SELECT count(*) FROM raw.{tbl}").fetchone()[0]
    print(f"{tbl:35s} {n:>10,}")

con.close()