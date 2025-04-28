import uuid
from datetime import datetime
from database_connector import DatabaseConnector
from s3_manager import S3Manager
import os, json

class DatabaseManager:
    def __init__(self):
        self.connector = DatabaseConnector()

    # User Management

    def get_user_id(self, email=None, name=None):
        try:
            if email:
                query = "SELECT id FROM users WHERE email = %s"
                params = (email,)
            elif name:
                query = "SELECT id FROM users WHERE name = %s"
                params = (name,)
            else:
                print("Either email or name must be provided.")
                return None
            
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            if result and result[0][0]:
                return result[0][0]
            return None
        except Exception as e:
            print(f"An error occurred while getting user ID: {e}")
            return None
    
    def add_user(self, name, email, password_hash, age, gender, fitness_level=None, profile_picture_url=None):
        try:
            user_id = uuid.uuid4()
            # password_hash to be done

            query = """
                INSERT INTO users (id, name, email, password_hash, age, gender, fitness_level, profile_picture_url)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            params = (str(user_id), name, email, password_hash, age, gender, fitness_level, profile_picture_url)
            self.connector.execute_query(query, params)
            print(f"User {name} added successfully.")
        except Exception as e:
            print(f"An error occurred while adding user {name}: {e}")
            return

    def get_user_profile(self, user_id):
        try:
            query = "SELECT * FROM users WHERE id = %s"
            params = (user_id,)
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            return result
        except Exception as e:
            print(f"An error occurred while fetching user profile for {user_id}: {e}")
            return None

    def update_user_profile(self, user_id, name=None, email=None, fitness_level=None):
        try: 
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

            if not update_fields:
                print(f"No fields provided for update for user {user_id}.")
                return

            params.append(user_id)

            query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = %s"
            
            self.connector.execute_query(query, tuple(params))
            print(f"User {user_id} profile updated with the provided fields.")
        except Exception as e:
            print(f"An error occurred while updating user {user_id}: {e}")
            return

    def update_profile_picture(self, user_id, profile_picture_key):
        try:
            query = "UPDATE users SET profile_picture_url = %s WHERE id = %s"
            params = (profile_picture_key, user_id)
            self.connector.execute_query(query, params)
            print(f"Profile picture updated for user {user_id}.")
            return True
        except Exception as e:
            print(f"An error occurred while updating profile picture for user {user_id}: {e}")
            return False

    def get_profile_picture_key(self, user_id):
        try:
            query = "SELECT profile_picture_url FROM users WHERE id = %s"
            params = (user_id,)
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            
            if result and result[0][0]:
                return result[0][0]
            return None
        except Exception as e:
            print(f"An error occurred while fetching profile picture key for user {user_id}: {e}")
            return None

    def clear_profile_picture(self, user_id):
        try:
            query = "UPDATE users SET profile_picture_url = NULL WHERE id = %s"
            params = (user_id,)
            self.connector.execute_query(query, params)
            print(f"Profile picture removed for user {user_id}.")
            return True
        except Exception as e:
            print(f"An error occurred while clearing profile picture for user {user_id}: {e}")
            return False

    def delete_user(self, user_id):
        try:
            query = "DELETE FROM users WHERE id = %s"
            params = (user_id,)
            self.connector.execute_query(query, params)
            print(f"User {user_id} deleted.")
        except Exception as e:
            print(f"An error occurred while deleting user {user_id}: {e}")
            return

    # Workout Management
    
    def get_exercise_list(self, category=None):
        try:
            file_path = os.path.join(os.path.dirname(__file__), 'exercises.json')
            
            with open(file_path, 'r') as file:
                data = json.load(file)
            
            exercises = data.get('exercises', [])
            
            if category:
                exercises = [ex for ex in exercises if ex['category'] == category]
            
            exercises.sort(key=lambda x: (x['category'], x['name']))
            
            return exercises

        except Exception as e:
            print(f"Error loading exercise list: {e}")
            return []

    def start_workout(self, user_id, date, name=None, notes=None):
        try:
            workout_id = uuid.uuid4()
            query = """
                INSERT INTO workouts (id, user_id, date, name, notes)
                VALUES (%s, %s, %s, %s, %s)
            """
            params = (str(workout_id), user_id, date, name, notes)
            self.connector.execute_query(query, params)
            print(f"Workout session started for user {user_id}.")
            return str(workout_id)
        except Exception as e:
            print(f"An error occurred while starting workout for user {user_id}: {e}")
            return None

    def log_exercise(self, workout_id, exercise, sets, reps, weight):
        try:
            exercise_id = uuid.uuid4()
            query = """
                INSERT INTO exercises (id, workout_id, exercise, sets, reps, weight)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            params = (str(exercise_id), workout_id, exercise, sets, reps, weight)
            self.connector.execute_query(query, params)
            print(f"Exercise logged for workout {workout_id}.")
            return str(exercise_id)
        except Exception as e:
            print(f"An error occurred while logging exercise for workout {workout_id}: {e}")
            return None

    def get_workout_exercises(self, workout_id):
        try:
            query = """
                SELECT id, exercise, sets, reps, weight, created_at
                FROM exercises
                WHERE workout_id = %s
                ORDER BY created_at
            """
            params = (workout_id,)
            exercises = self.connector.execute_query(query, params, commit=False, fetch=True)
            return exercises
        except Exception as e:
            print(f"An error occurred while fetching exercises for workout {workout_id}: {e}")
            return None

    def update_exercise(self, exercise_id, exercise=None, sets=None, reps=None, weight=None):
        try:
            columns_to_update = []
            params = []

            if exercise is not None:
                columns_to_update.append("exercise = %s")
                params.append(exercise)
            
            if sets is not None:
                columns_to_update.append("sets = %s")
                params.append(sets)
            
            if reps is not None:
                columns_to_update.append("reps = %s")
                params.append(reps)
            
            if weight is not None:
                columns_to_update.append("weight = %s")
                params.append(weight)

            if not columns_to_update:
                print("No updates provided.")
                return False

            params.append(exercise_id)

            query = f"""
                UPDATE exercises SET {', '.join(columns_to_update)} WHERE id = %s
            """
            
            self.connector.execute_query(query, tuple(params))
            print(f"Exercise {exercise_id} updated.")
            return True
        except Exception as e:
            print(f"An error occurred while updating exercise {exercise_id}: {e}")
            return False

    def delete_exercise(self, exercise_id):
        try:
            query = "DELETE FROM exercises WHERE id = %s"
            params = (exercise_id,)
            self.connector.execute_query(query, params)
            print(f"Exercise {exercise_id} deleted.")
            return True
        except Exception as e:
            print(f"An error occurred while deleting exercise {exercise_id}: {e}")
            return False

    def get_user_workouts(self, user_id):
        try:
            query = """
                SELECT w.id, w.date, w.name, w.notes, w.created_at,
                    COUNT(e.id) AS exercise_count,
                    SUM(e.sets * e.reps * e.weight) AS total_weight_lifted
                FROM workouts w
                LEFT JOIN exercises e ON w.id = e.workout_id
                WHERE w.user_id = %s
                GROUP BY w.id
                ORDER BY w.date DESC
            """
            params = (user_id,)
            workouts = self.connector.execute_query(query, params, commit=False, fetch=True)
            return workouts
        except Exception as e:
            print(f"An error occurred while fetching workouts for user {user_id}: {e}")
            return None

    def update_workout(self, workout_id, date=None, name=None, notes=None):
        try:
            columns_to_update = []
            params = []

            if date is not None:
                columns_to_update.append("date = %s")
                params.append(date)
            
            if name is not None:
                columns_to_update.append("name = %s")
                params.append(name)
            
            if notes is not None:
                columns_to_update.append("notes = %s")
                params.append(notes)

            if not columns_to_update:
                print("No updates provided.")
                return False

            params.append(workout_id)

            query = f"""
                UPDATE workouts SET {', '.join(columns_to_update)} WHERE id = %s
            """
            
            self.connector.execute_query(query, tuple(params))
            print(f"Workout {workout_id} updated.")
            return True
        except Exception as e:
            print(f"An error occurred while updating workout {workout_id}: {e}")
            return False

    def delete_workout(self, workout_id):
        try:
            query = "DELETE FROM workouts WHERE id = %s"
            params = (workout_id,)
            self.connector.execute_query(query, params)
            print(f"Workout {workout_id} and all its exercises deleted.")
            return True
        except Exception as e:
            print(f"An error occurred while deleting workout {workout_id}: {e}")
            return False

    # can remove this function and keep it only for python
    def get_total_weight_lifted(self, user_id):
        try:
            query = "SELECT SUM(sets * reps * weight) FROM workouts WHERE user_id = %s"
            params = (user_id,)
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            if result and result[0][0] is not None:
                return result[0][0]
            else:
                return 0
        except Exception as e:
            print(f"An error occurred while fetching total weight lifted for user {user_id}: {e}")
            return None

    # Measurement Management

    def add_measurement(self, user_id, weight, bmi, body_fat_percentage, muscle_mass, date):
        try:
            measurement_id = uuid.uuid4()
            query = """
                INSERT INTO measurements (id, user_id, weight, bmi, body_fat_percentage, muscle_mass, date_recorded)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            params = (str(measurement_id), user_id, weight, bmi, body_fat_percentage, muscle_mass, date)
            self.connector.execute_query(query, params)
            print(f"Measurement for user {user_id} added.")
        except Exception as e:
            print(f"An error occurred while adding measurement for user {user_id}: {e}")
            return

    def get_measurements(self, user_id):
        try:
            query = "SELECT * FROM measurements WHERE user_id = %s"
            params = (user_id,)
            measurements = self.connector.execute_query(query, params, commit=False, fetch=True)
            return measurements
        except Exception as e:
            print(f"An error occurred while fetching measurements for user {user_id}: {e}")
            return None

    def update_measurement(self, measurement_id, weight=None, bmi=None, body_fat_percentage=None, muscle_mass=None):
        try:
            columns_to_update = []
            params = []
            if weight is not None:
                columns_to_update.append("weight = %s")
                params.append(weight)
            if bmi is not None:
                columns_to_update.append("bmi = %s")
                params.append(bmi)
            if body_fat_percentage is not None:
                columns_to_update.append("body_fat_percentage = %s")
                params.append(body_fat_percentage)
            if muscle_mass is not None:
                columns_to_update.append("muscle_mass = %s")
                params.append(muscle_mass)
            
            params.append(measurement_id)
            
            if not columns_to_update:
                print("No updates provided.")
                return

            query = f"""
                UPDATE measurements SET {', '.join(columns_to_update)} WHERE id = %s
            """

            self.connector.execute_query(query, tuple(params))
            print(f"Measurement {measurement_id} updated.")
            
        except Exception as e:
            print(f"An error occurred while updating measurement {measurement_id}: {e}")
            return

    def get_total_weight_lifted(self, user_id):
        """
        Calculate the total weight lifted by a user across all exercises
        
        Args:
            user_id (str): UUID of the user
        
        Returns:
            float: Total weight lifted by the user
        """
        try:
            query = """
                SELECT SUM(e.sets * e.reps * e.weight)
                FROM exercises e
                JOIN workouts w ON e.workout_id = w.id
                WHERE w.user_id = %s
            """
            params = (user_id,)
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            if result and result[0][0] is not None:
                return result[0][0]
            else:
                return 0
        except Exception as e:
            print(f"An error occurred while fetching total weight lifted for user {user_id}: {e}")
            return None

    # Leaderboard Data Management

    def update_leaderboard(self):
        try:
            query = """
            WITH leaderboard_data AS (
                SELECT 
                    w.user_id,
                    SUM(e.sets * e.reps * e.weight) AS total_weight_lifted,
                    COUNT(DISTINCT w.id) AS workout_days_count,
                    MAX(w.date) AS last_workout
                FROM workouts w
                JOIN exercises e ON w.id = e.workout_id
                GROUP BY w.user_id
            )
            
            INSERT INTO leaderboard (user_id, total_weight_lifted, workout_days_count, last_workout, updated_at)
            SELECT 
                user_id, 
                total_weight_lifted, 
                workout_days_count, 
                last_workout, 
                NOW()
            FROM leaderboard_data
            ON CONFLICT (user_id) DO UPDATE
            SET 
                total_weight_lifted = excluded.total_weight_lifted,
                workout_days_count = excluded.workout_days_count,
                last_workout = excluded.last_workout,
                updated_at = NOW();
            """
            
            self.connector.execute_query(query)
            print("Leaderboard updated successfully.")
        except Exception as e:
            print(f"An error occurred while updating the leaderboard: {e}")

    def get_leaderboard(self, limit=10, start_date=None, end_date=None):
        try:
            if start_date or end_date:
                params = []
                date_filter = ""
                
                if start_date and end_date:
                    date_filter = "WHERE w.date BETWEEN %s AND %s"
                    params = [start_date, end_date]
                elif start_date:
                    date_filter = "WHERE w.date >= %s"
                    params = [start_date]
                elif end_date:
                    date_filter = "WHERE w.date <= %s"
                    params = [end_date]
                    
                params.append(limit)
                
                query = f"""
                SELECT 
                    u.name,
                    SUM(e.sets * e.reps * e.weight) AS total_weight_lifted,
                    COUNT(DISTINCT w.id) AS workout_days_count,
                    MAX(w.date) AS last_workout
                FROM users u
                JOIN workouts w ON u.id = w.user_id
                JOIN exercises e ON w.id = e.workout_id
                {date_filter}
                GROUP BY u.id, u.name
                ORDER BY total_weight_lifted DESC
                LIMIT %s
                """
                
                leaderboard = self.connector.execute_query(query, tuple(params), commit=False, fetch=True)
                return leaderboard
            else:
                query = """
                SELECT 
                    u.name,
                    l.total_weight_lifted,
                    l.workout_days_count,
                    l.last_workout
                FROM leaderboard l
                JOIN users u ON l.user_id = u.id
                ORDER BY l.total_weight_lifted DESC
                LIMIT %s
                """
                params = (limit,)
                leaderboard = self.connector.execute_query(query, params, commit=False, fetch=True)
                return leaderboard
        except Exception as e:
            print(f"An error occurred while fetching leaderboard: {e}")
            return None
    
    def get_user_ranking(self, user_id):
        query = "SELECT rank() OVER (ORDER BY total_weight_lifted DESC) FROM leaderboard WHERE user_id = %s"
        params = (user_id,)
        result = self.connector.execute_query(query, params, commit=False, fetch=True)
        return result[0][0] if result else None

    # Social Management

    def follow_user(self, follower_id, following_id):
        try:
            if follower_id == following_id:
                print("Users cannot follow themselves.")
                return False
                
            query = """
                INSERT INTO user_follows (follower_id, following_id)
                VALUES (%s, %s)
            """
            params = (follower_id, following_id)
            self.connector.execute_query(query, params)
            print(f"User {follower_id} is now following user {following_id}.")
            return True
        except Exception as e:
            print(f"An error occurred while following user: {e}")
            return False

    def unfollow_user(self, follower_id, following_id):
        try:
            query = """
                DELETE FROM user_follows
                WHERE follower_id = %s AND following_id = %s
            """
            params = (follower_id, following_id)
            self.connector.execute_query(query, params)
            print(f"User {follower_id} has unfollowed user {following_id}.")
            return True
        except Exception as e:
            print(f"An error occurred while unfollowing user: {e}")
            return False

    def get_followers(self, user_id):
        try:
            query = """
                SELECT u.id, u.name, u.profile_picture_url
                FROM user_follows f
                JOIN users u ON f.follower_id = u.id
                WHERE f.following_id = %s
                ORDER BY f.created_at DESC
            """
            params = (user_id,)
            followers = self.connector.execute_query(query, params, commit=False, fetch=True)
            return followers
        except Exception as e:
            print(f"An error occurred while fetching followers: {e}")
            return None

    def get_following(self, user_id):
        try:
            query = """
                SELECT u.id, u.name, u.profile_picture_url
                FROM user_follows f
                JOIN users u ON f.following_id = u.id
                WHERE f.follower_id = %s
                ORDER BY f.created_at DESC
            """
            params = (user_id,)
            following = self.connector.execute_query(query, params, commit=False, fetch=True)
            return following
        except Exception as e:
            print(f"An error occurred while fetching following: {e}")
            return None

    def is_following(self, follower_id, following_id):
        try:
            query = """
                SELECT EXISTS(
                    SELECT 1 FROM user_follows
                    WHERE follower_id = %s AND following_id = %s
                )
            """
            params = (follower_id, following_id)
            result = self.connector.execute_query(query, params, commit=False, fetch=True)
            return result[0][0] if result else False
        except Exception as e:
            print(f"An error occurred while checking follow status: {e}")
            return False

    # Feed Management

    def get_workout_feed(self, user_id, limit=20, offset=0, include_viewed=False):
        try:
            viewed_clause = "" if include_viewed else f"""
                AND NOT EXISTS (
                    SELECT 1 FROM workout_views
                    WHERE workout_id = w.id AND viewer_id = %s
                )
            """
            
            query = f"""
                SELECT 
                    w.id,
                    w.date,
                    w.name,
                    u.id AS user_id,
                    u.name AS user_name,
                    u.profile_picture_url,
                    COUNT(e.id) AS exercise_count,
                    SUM(e.sets * e.reps * e.weight) AS total_weight_lifted
                FROM workouts w
                JOIN users u ON w.user_id = u.id
                LEFT JOIN exercises e ON w.id = e.workout_id
                WHERE w.user_id IN (
                    SELECT following_id
                    FROM user_follows
                    WHERE follower_id = %s
                )
                {viewed_clause}
                GROUP BY w.id, u.id
                ORDER BY w.date DESC
                LIMIT %s OFFSET %s
            """
            
            params = [user_id, user_id] if not include_viewed else [user_id]
            params.extend([limit, offset])
            
            feed_items = self.connector.execute_query(query, tuple(params), commit=False, fetch=True)
            return feed_items
        except Exception as e:
            print(f"An error occurred while fetching workout feed: {e}")
            return None

    def get_workout_details(self, workout_id):
        try:
            # Get workout information
            workout_query = """
                SELECT w.id, w.date, w.name, w.notes, u.id AS user_id, u.name AS user_name, u.profile_picture_url
                FROM workouts w
                JOIN users u ON w.user_id = u.id
                WHERE w.id = %s
            """
            workout_params = (workout_id,)
            workout_result = self.connector.execute_query(workout_query, workout_params, commit=False, fetch=True)
            
            if not workout_result:
                return None
            
            # Get exercises for the workout
            exercises_query = """
                SELECT id, exercise, sets, reps, weight, created_at
                FROM exercises
                WHERE workout_id = %s
                ORDER BY created_at
            """
            exercises_params = (workout_id,)
            exercises_result = self.connector.execute_query(exercises_query, exercises_params, commit=False, fetch=True)
            
            # Format the results
            workout_info = {
                'id': workout_result[0][0],
                'date': workout_result[0][1],
                'name': workout_result[0][2],
                'notes': workout_result[0][3],
                'user_id': workout_result[0][4],
                'user_name': workout_result[0][5],
                'profile_picture_url': workout_result[0][6],
                'exercises': []
            }
            
            for exercise in exercises_result:
                workout_info['exercises'].append({
                    'id': exercise[0],
                    'exercise': exercise[1],
                    'sets': exercise[2],
                    'reps': exercise[3],
                    'weight': exercise[4],
                    'created_at': exercise[5]
                })
            
            return workout_info
        except Exception as e:
            print(f"An error occurred while fetching workout details for {workout_id}: {e}")
            return None

    def mark_workout_viewed(self, workout_id, viewer_id):
        try:
            view_id = uuid.uuid4()
            query = """
                INSERT INTO workout_views (id, workout_id, viewer_id)
                VALUES (%s, %s, %s)
                ON CONFLICT (workout_id, viewer_id) DO NOTHING
            """
            params = (str(view_id), workout_id, viewer_id)
            self.connector.execute_query(query, params)
            return True
        except Exception as e:
            print(f"An error occurred while marking workout as viewed: {e}")
            return False

class ProfilePictureHandler:
    def __init__(self):
        self.s3_manager = S3Manager()
        self.db_manager = DatabaseManager()
    
    def upload_profile_picture(self, user_id, image_data, content_type):
        existing_key = self.db_manager.get_profile_picture_key(user_id)
        
        if existing_key:
            self.s3_manager.delete_profile_picture(existing_key)
        
        s3_key = self.s3_manager.upload_profile_picture(user_id, image_data, content_type)
        
        if not s3_key:
            return False
        
        return self.db_manager.update_profile_picture(user_id, s3_key)
    
    def get_profile_picture(self, user_id):
        s3_key = self.db_manager.get_profile_picture_key(user_id)
        
        if not s3_key:
            return None, None
        
        return self.s3_manager.get_profile_picture_data(s3_key)
    
    def get_profile_picture_url(self, user_id, expiration=3600):
        s3_key = self.db_manager.get_profile_picture_key(user_id)
        
        if not s3_key:
            return None
        
        return self.s3_manager.get_profile_picture_url(s3_key, expiration)
    
    def delete_profile_picture(self, user_id):
        s3_key = self.db_manager.get_profile_picture_key(user_id)
        
        if not s3_key:
            return True 
        
        if not self.s3_manager.delete_profile_picture(s3_key):
            return False
        
        return self.db_manager.clear_profile_picture(user_id)