from kaggle.api.kaggle_api_extended import KaggleApi

api = KaggleApi()
api.authenticate()

api.dataset_download_files(
    "olistbr/brazilian-ecommerce",
    path="data/raw",
    unzip=True
)

import subprocess
import sys

from pathlib import Path

script_path = Path(__file__).resolve().parent.parent / "scripts" / "load_to_duckdb.py"
subprocess.run([sys.executable, str(script_path)], check=True)
