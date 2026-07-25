# ui.py
import duckdb

con = duckdb.connect("olist.duckdb")
con.sql("CALL start_ui()")
input("UI calisiyor. Kapatmak icin Enter...")
con.close()