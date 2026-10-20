import os
import requests
import psycopg2
from datetime import datetime

# 1. RETRIEVE ENVIRONMENT PARAMETERS
DB_HOST = os.getenv("DBT_ENV_POSTGRES_HOST", "localhost")
DB_PORT = os.getenv("DBT_ENV_POSTGRES_PORT", 5432)
DB_USER = os.getenv("DBT_ENV_POSTGRES_USER", "postgres")
DB_PASS = os.getenv("DBT_ENV_POSTGRES_PASS", "postgres")
DB_NAME = os.getenv("DBT_ENV_POSTGRES_DBNAME", "jaffle_retail")

API_KEY = os.getenv("DBT_ENV_COINGECKO_KEY")

API_URL = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"

def run_pipeline():
    print(f"[{datetime.now()}] >>> Pipeline Execution Initiated.")
    
    headers = {
        "User-Agent": "DataPipelineAgent/1.0",
        "Accept": "application/json",
        "x-cg-demo-api-key": API_KEY 
    }
    
    try:
        print("Extracting current market stats using Developer Key...")
        response = requests.get(API_URL, headers=headers, timeout=15)
        response.raise_for_status()
        market_data = response.json()
        print(f"Extraction Successful. Retrieved {len(market_data)} asset objects.")
    except Exception as err:
        print(f"CRITICAL SYSTEM FAILURE during Extract: {err}")
        if 'response' in locals():
            print(f"Server Response Content: {response.text[:200]}") 
        return

    connection = None
    cursor = None
    try:
        print(f"Connecting to Data Warehouse target container [{DB_NAME}]...")
        connection = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS, database=DB_NAME
        )
        cursor = connection.cursor()
        
        insert_statement = """
            INSERT INTO raw_source.api_crypto_tickers 
            (coin_id, coin_symbol, coin_name, current_price, market_cap, total_volume)
            VALUES (%s, %s, %s, %s, %s, %s);
        """
        
        print("Streaming batch transactions into raw_source.api_crypto_tickers...")
        for coin in market_data:
            cursor.execute(insert_statement, (
                coin.get('id'),
                coin.get('symbol', '').upper(),
                coin.get('name'),
                coin.get('current_price'),
                coin.get('market_cap'),
                coin.get('total_volume')
            ))
            
        connection.commit()
        print("Load Step Complete. Database transaction committed cleanly.")
        
    except Exception as db_err:
        print(f"CRITICAL SYSTEM FAILURE during Load: {db_err}")
        if connection:
            connection.rollback()
    finally:
        if cursor: cursor.close()
        if connection: connection.close()
        print(f"[{datetime.now()}] >>> Connection Pool Terminated Safely.")

if __name__ == "__main__":
    run_pipeline()
