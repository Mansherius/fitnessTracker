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
            self.cursor.execute(query, params)
            
            if commit:
                self.connection.commit()
            
            if fetch:
                return self.cursor.fetchall()

        except psycopg2.errors.UniqueViolation as e:
            print(f"Unique violation error: {e}")
            raise ValueError("Duplicate value error: A unique constraint has been violated.")
        
        except psycopg2.errors.ForeignKeyViolation as e:
            print(f"Foreign key violation error: {e}")
            raise ValueError("Foreign key constraint violation.")
        
        except psycopg2.errors.CheckViolation as e:
            print(f"Check constraint violation error: {e}")
            raise ValueError("Check constraint violation.")
        
        except psycopg2.DatabaseError as e:
            print(f"Database error occurred: {e}")
            self.connection.rollback()
            raise ValueError("A database error occurred during the query execution.")
        
        except Exception as e:
            # Catch any other errors
            print(f"An unexpected error occurred: {e}")
            self.connection.rollback()
            raise e


    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            print("Database connection closed.")
