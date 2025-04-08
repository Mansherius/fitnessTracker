from config import DB_CONFIG
import psycopg2

class DatabaseConnector:
    def __init__(self):
        self.db_config = DB_CONFIG
        self.connection = None
        self.cursor = None
        self.connect()
    
    def connect(self):
        self.connection = psycopg2.connect(
            host=self.db_config['host'],
            database=self.db_config['database'],
            user=self.db_config['user'],
            password=self.db_config['password']
        )

        self.cursor = self.connection.cursor()

        if self.connection:
            print("Database connection established.")
        else:
            print("Failed to connect to the database.")

    def execute_query(self, query, params=None, commit=True, fetch=False):
        if self.connection is None:
            self.connect()
        try:
            self.cursor.execute(query, params)  # Pass the params here
            if commit:
                self.connection.commit()
            if fetch:  # If fetch is True, fetch results
                return self.cursor.fetchall()
        except Exception as e:
            print(f"An error occurred: {e}")
            self.connection.rollback()


    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            print("Database connection closed.")
