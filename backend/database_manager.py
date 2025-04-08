import uuid
from datetime import datetime
from database_connector import DatabaseConnector

class DatabaseManager:
    def __init__(self):
        self.connector = DatabaseConnector()

    def add_user(self, name, email, password_hash, age, gender, fitness_level=None, profile_picture_url=None):
        user_id = uuid.uuid4()
        # password_hash to be done

        query = """
            INSERT INTO users (id, name, email, password_hash, age, gender, fitness_level, profile_picture_url)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (str(user_id), name, email, password_hash, age, gender, fitness_level, profile_picture_url)
        self.connector.execute_query(query, params)
        print(f"User {name} added successfully.")

    def get_user_profile(self, user_id):
        query = "SELECT * FROM users WHERE id = %s"
        params = (user_id,)
        result = self.connector.execute_query(query, params, commit=False, fetch=True)
        return result

    def update_user_profile(self, user_id, name=None, email=None, fitness_level=None, profile_picture_url=None):
        update_fields = []
        params = []

        if name is not None:
            update_fields.append("name = %s")
            params.append(name)
        
        if email is not None:
            update_fields.append("email = %s")
            params.append(email)
        
        if fitness_level is not None:
            update_fields.append("fitness_level = %s")
            params.append(fitness_level)
        
        if profile_picture_url is not None:
            update_fields.append("profile_picture_url = %s")
            params.append(profile_picture_url)

        if not update_fields:
            print(f"No fields provided for update for user {user_id}.")
            return

        params.append(user_id)

        query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = %s"
        
        self.connector.execute_query(query, tuple(params))
        print(f"User {user_id} profile updated with the provided fields.")


    def delete_user(self, user_id):
        query = "DELETE FROM users WHERE id = %s"
        params = (user_id,)
        self.connector.execute_query(query, params)
        print(f"User {user_id} deleted.")

    # Workout Management

    def add_workout(self, user_id, exercise, sets, reps, weight, date):
        workout_id = uuid.uuid4()
        query = """
            INSERT INTO workouts (id, user_id, date, exercise, sets, reps, weight)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        params = (workout_id, user_id, date, exercise, sets, reps, weight)
        self.connector.execute_query(query, params)
        print(f"Workout for user {user_id} added.")

    def get_workouts(self, user_id):
        query = "SELECT * FROM workouts WHERE user_id = %s"
        params = (user_id,)
        workouts = self.connector.execute_query(query, params, commit=False, fetch=True)
        return workouts

    def update_workout(self, workout_id, exercise=None, sets=None, reps=None, weight=None):
        query = """
            UPDATE workouts SET exercise = %s, sets = %s, reps = %s, weight = %s WHERE id = %s
        """
        params = (exercise, sets, reps, weight, workout_id)
        self.connector.execute_query(query, params)
        print(f"Workout {workout_id} updated.")

    def delete_workout(self, workout_id):
        query = "DELETE FROM workouts WHERE id = %s"
        params = (workout_id,)
        self.connector.execute_query(query, params)
        print(f"Workout {workout_id} deleted.")

    def get_total_weight_lifted(self, user_id):
        query = "SELECT SUM(weight) FROM workouts WHERE user_id = %s"
        params = (user_id,)
        result = self.connector.execute_query(query, params, commit=False, fetch=True)
        return result[0][0] if result else 0

    # Measurement Management

    def add_measurement(self, user_id, weight, bmi, body_fat_percentage, muscle_mass, date):
        measurement_id = uuid.uuid4()
        query = """
            INSERT INTO measurements (id, user_id, weight, bmi, body_fat_percentage, muscle_mass, date_recorded)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        params = (measurement_id, user_id, weight, bmi, body_fat_percentage, muscle_mass, date)
        self.connector.execute_query(query, params)
        print(f"Measurement for user {user_id} added.")

    def get_measurements(self, user_id):
        query = "SELECT * FROM measurements WHERE user_id = %s"
        params = (user_id,)
        measurements = self.connector.execute_query(query, params, commit=False, fetch=True)
        return measurements

    def update_measurement(self, measurement_id, weight=None, bmi=None, body_fat_percentage=None, muscle_mass=None):
        query = """
            UPDATE measurements SET weight = %s, bmi = %s, body_fat_percentage = %s, muscle_mass = %s
            WHERE id = %s
        """
        params = (weight, bmi, body_fat_percentage, muscle_mass, measurement_id)
        self.connector.execute_query(query, params)
        print(f"Measurement {measurement_id} updated.")

    def delete_measurement(self, measurement_id):
        query = "DELETE FROM measurements WHERE id = %s"
        params = (measurement_id,)
        self.connector.execute_query(query, params)
        print(f"Measurement {measurement_id} deleted.")

    def get_leaderboard(self, limit=10):
        query = "SELECT user_id, total_weight_lifted FROM leaderboard ORDER BY total_weight_lifted DESC LIMIT %s"
        params = (limit,)
        leaderboard = self.connector.execute_query(query, params, commit=False, fetch=True)
        return leaderboard

    def update_leaderboard(self, user_id, total_weight_lifted, workout_days_count, streak_count):
        query = """
            INSERT INTO leaderboard (user_id, total_weight_lifted, workout_days_count, streak_count, updated_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (user_id) DO UPDATE
            SET total_weight_lifted = %s, workout_days_count = %s, streak_count = %s, updated_at = %s
        """
        params = (user_id, total_weight_lifted, workout_days_count, streak_count, datetime.now(), total_weight_lifted, workout_days_count, streak_count, datetime.now())
        self.connector.execute_query(query, params)
        print(f"Leaderboard for user {user_id} updated.")

    def get_user_ranking(self, user_id):
        query = "SELECT rank() OVER (ORDER BY total_weight_lifted DESC) FROM leaderboard WHERE user_id = %s"
        params = (user_id,)
        result = self.connector.execute_query(query, params, commit=False, fetch=True)
        return result[0][0] if result else None