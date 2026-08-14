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

subprocess.run(
    [sys.executable, "..\scripts\load_to_duckdb.py"],
    check=True
)
