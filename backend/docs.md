# Fitness Tracker API Documentation

This documentation describes the backend API for the Fitness Tracker application, focusing on the `DatabaseManager` class which serves as the primary interface for the middle layer.

## DatabaseManager

The `DatabaseManager` class provides methods for interacting with the Fitness Tracker database. It handles user management, workouts, measurements, leaderboards, and social features.

### Initialization

```python
from database_manager import DatabaseManager
dbm = DatabaseManager()
```

## User Management

### get_user_id

Gets a user's UUID by email or name.

```python
def get_user_id(self, email=None, name=None)
```

**Parameters:**
- `email` (str, optional): User's email address
- `name` (str, optional): User's name

**Returns:**
- `str`: UUID of the user, or None if not found

### add_user

Adds a new user to the database.

```python
def add_user(self, name, email, password_hash, age, gender, fitness_level=None, profile_picture_url=None)
```

**Parameters:**
- `name` (str): User's full name
- `email` (str): User's email address (must be unique)
- `password_hash` (str): Hashed password
- `age` (int): User's age
- `gender` (str): User's gender
- `fitness_level` (str, optional): User's fitness level (e.g., "beginner", "intermediate", "advanced")
- `profile_picture_url` (str, optional): S3 key for the user's profile picture

**Returns:**
- None

**Example:**
```python
dbm.add_user(
    name="Aaryan Nagpal",
    email="aaryannagpal65@gmail.com", 
    password_hash="ToHASHthis",
    age=21,
    gender="Male",
    fitness_level="Beginner"
)
# Output: User Aaryan Nagpal added successfully.
```

### get_user_profile

Retrieves a user's profile information.

```python
def get_user_profile(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- List of tuples containing user information, or None if an error occurs

**Example:**
```python
results = dbm.get_user_profile(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Results contain: id, name, email, password_hash, age, gender, fitness_level, profile_picture_url, created_at, updated_at
```

### update_user_profile

Updates a user's profile information.

```python
def update_user_profile(self, user_id, name=None, email=None, fitness_level=None)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `name` (str, optional): New name
- `email` (str, optional): New email
- `fitness_level` (str, optional): New fitness level

**Returns:**
- None

**Example:**
```python
dbm.update_user_profile(
    user_id='4373271c-5141-433e-b868-5f1a2c9174f1',
    name="Aaryan Nagpal"
)
# Output: User 4373271c-5141-433e-b868-5f1a2c9174f1 profile updated with the provided fields.
```

### delete_user

Deletes a user from the database.

```python
def delete_user(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user to delete

**Returns:**
- None

**Example:**
```python
dbm.delete_user(user_id='1605ccb8-232a-4930-89f3-830a1bb49669')
# Output: User 1605ccb8-232a-4930-89f3-830a1bb49669 deleted.
```

## Profile Picture Management

### update_profile_picture

Updates a user's profile picture in the database.

```python
def update_profile_picture(self, user_id, profile_picture_key)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `profile_picture_key` (str): S3 key for the profile picture

**Returns:**
- `bool`: True if successful, False otherwise

### get_profile_picture_key

Retrieves the S3 key for a user's profile picture.

```python
def get_profile_picture_key(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- `str`: S3 key for the profile picture, or None if not found

### clear_profile_picture

Removes a user's profile picture reference from the database.

```python
def clear_profile_picture(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- `bool`: True if successful, False otherwise

## Workout Management

### start_workout

Starts a new workout session for a user.

```python
def start_workout(self, user_id, date, name=None, notes=None)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `date` (datetime/str): Date of the workout
- `name` (str, optional): Name of the workout (e.g., "Leg Day")
- `notes` (str, optional): Additional notes about the workout

**Returns:**
- `str`: UUID of the created workout, or None if an error occurs

**Example:**
```python
workout_id = dbm.start_workout(
    user_id='4373271c-5141-433e-b868-5f1a2c9174f1',
    date="2025-04-27",
    name="Monday Leg Day"
)
# Output: Workout session started for user 4373271c-5141-433e-b868-5f1a2c9174f1.
```

### log_exercise

Logs an exercise in a workout session.

```python
def log_exercise(self, workout_id, exercise, sets, reps, weight)
```

**Parameters:**
- `workout_id` (str): UUID of the workout
- `exercise` (str): Name of the exercise
- `sets` (int): Number of sets
- `reps` (int): Number of repetitions
- `weight` (float): Weight used in the exercise

**Returns:**
- `str`: UUID of the created exercise, or None if an error occurs

**Example:**
```python
exercise_id = dbm.log_exercise(
    workout_id='2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d',
    exercise="Leg Press",
    sets=3,
    reps=10,
    weight=70
)
# Output: Exercise logged for workout 2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d.
```

### get_workout_exercises

Gets all exercises for a workout.

```python
def get_workout_exercises(self, workout_id)
```

**Parameters:**
- `workout_id` (str): UUID of the workout

**Returns:**
- List of tuples containing exercise information, or None if an error occurs

**Example:**
```python
exercises = dbm.get_workout_exercises(workout_id='2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d')
# Results contain: id, exercise, sets, reps, weight, created_at
```

### update_exercise

Updates an exercise in a workout.

```python
def update_exercise(self, exercise_id, exercise=None, sets=None, reps=None, weight=None)
```

**Parameters:**
- `exercise_id` (str): UUID of the exercise
- `exercise` (str, optional): New exercise name
- `sets` (int, optional): New number of sets
- `reps` (int, optional): New number of repetitions
- `weight` (float, optional): New weight

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
dbm.update_exercise(
    exercise_id='3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r',
    weight=75
)
# Output: Exercise 3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r updated.
```

### delete_exercise

Deletes an exercise from a workout.

```python
def delete_exercise(self, exercise_id)
```

**Parameters:**
- `exercise_id` (str): UUID of the exercise

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
dbm.delete_exercise(exercise_id='3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r')
# Output: Exercise 3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r deleted.
```

### get_user_workouts

Gets all workouts for a user.

```python
def get_user_workouts(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- List of tuples containing workout information, or None if an error occurs

**Example:**
```python
workouts = dbm.get_user_workouts(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Results contain: id, date, name, notes, created_at, exercise_count, total_weight_lifted
```

### update_workout

Updates a workout session.

```python
def update_workout(self, workout_id, date=None, name=None, notes=None)
```

**Parameters:**
- `workout_id` (str): UUID of the workout
- `date` (datetime/str, optional): New date
- `name` (str, optional): New name
- `notes` (str, optional): New notes

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
dbm.update_workout(
    workout_id='2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d',
    name="Updated Leg Day"
)
# Output: Workout 2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d updated.
```

### delete_workout

Deletes a workout and all its exercises.

```python
def delete_workout(self, workout_id)
```

**Parameters:**
- `workout_id` (str): UUID of the workout

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
dbm.delete_workout(workout_id='2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d')
# Output: Workout 2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d and all its exercises deleted.
```

### get_workout_details

Gets detailed information about a workout including all exercises.

```python
def get_workout_details(self, workout_id)
```

**Parameters:**
- `workout_id` (str): UUID of the workout

**Returns:**
- `dict`: Dictionary containing workout details and exercises, or None if not found

**Example:**
```python
details = dbm.get_workout_details(workout_id='2a8b9c7d-6e5f-4a3b-2c1d-0e9f8a7b6c5d')
# Returns a dictionary with workout details and a list of exercises
```

### get_total_weight_lifted

Calculates the total weight lifted by a user across all exercises.

```python
def get_total_weight_lifted(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- `float`: Total weight lifted by the user, or None if an error occurs

**Example:**
```python
result = dbm.get_total_weight_lifted(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Output: 5449.0
```

## Measurement Management

### add_measurement

Adds a new body measurement for a user.

```python
def add_measurement(self, user_id, weight, bmi, body_fat_percentage, muscle_mass, date)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `weight` (float): User's weight
- `bmi` (float): Body Mass Index
- `body_fat_percentage` (float): Body fat percentage
- `muscle_mass` (float): Muscle mass
- `date` (datetime/str): Date of measurement

**Returns:**
- None

**Example:**
```python
dbm.add_measurement(
    user_id='4373271c-5141-433e-b868-5f1a2c9174f1',
    weight=70,
    bmi=22,
    body_fat_percentage=15,
    muscle_mass=55,
    date="2023-10-02"
)
# Output: Measurement for user 4373271c-5141-433e-b868-5f1a2c9174f1 added.
```

### get_measurements

Retrieves all measurements for a user.

```python
def get_measurements(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- List of tuples containing measurement information, or None if an error occurs

**Example:**
```python
results = dbm.get_measurements(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Results contain: id, user_id, weight, bmi, body_fat_percentage, muscle_mass, date
```

### update_measurement

Updates an existing measurement.

```python
def update_measurement(self, measurement_id, weight=None, bmi=None, body_fat_percentage=None, muscle_mass=None)
```

**Parameters:**
- `measurement_id` (str): UUID of the measurement
- `weight` (float, optional): New weight
- `bmi` (float, optional): New BMI
- `body_fat_percentage` (float, optional): New body fat percentage
- `muscle_mass` (float, optional): New muscle mass

**Returns:**
- None

**Example:**
```python
dbm.update_measurement(
    measurement_id='59611075-2366-45f7-b809-ea35ae619453',
    weight=72
)
# Output: Measurement 59611075-2366-45f7-b809-ea35ae619453 updated.
```

### delete_measurement

Deletes a measurement.

```python
def delete_measurement(self, measurement_id)
```

**Parameters:**
- `measurement_id` (str): UUID of the measurement to delete

**Returns:**
- None

**Example:**
```python
dbm.delete_measurement(measurement_id='59611075-2366-45f7-b809-ea35ae619453')
# Output: Measurement 59611075-2366-45f7-b809-ea35ae619453 deleted.
```

## Leaderboard Management

### update_leaderboard

Updates the leaderboard with current workout data.

```python
def update_leaderboard(self)
```

**Parameters:**
- None

**Returns:**
- None

**Example:**
```python
dbm.update_leaderboard()
# Output: Leaderboard updated successfully.
```

### get_leaderboard

Retrieves the leaderboard, optionally filtered by date range.

```python
def get_leaderboard(self, limit=10, start_date=None, end_date=None)
```

**Parameters:**
- `limit` (int, optional): Maximum number of entries to return (default: 10)
- `start_date` (datetime/str, optional): Filter workouts after this date
- `end_date` (datetime/str, optional): Filter workouts before this date

**Returns:**
- List of tuples containing leaderboard information, or None if an error occurs

**Example:**
```python
# Get overall leaderboard
results = dbm.get_leaderboard()
# Output: List of tuples with user, total_weight_lifted, workouts_done, last_workout_date

# Get date-filtered leaderboard
results = dbm.get_leaderboard(start_date="2025-01-01", end_date="2025-03-31")
# Output: Date-filtered leaderboard results
```

### get_user_ranking

Gets a user's ranking on the leaderboard.

```python
def get_user_ranking(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- `int`: User's ranking on the leaderboard, or None if not found

**Example:**
```python
rank = dbm.get_user_ranking(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Output: 1 (indicating 1st place on the leaderboard)
```

## Social Following Management

### follow_user

Creates a follow relationship between two users.

```python
def follow_user(self, follower_id, following_id)
```

**Parameters:**
- `follower_id` (str): UUID of the user who is following
- `following_id` (str): UUID of the user being followed

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
result = dbm.follow_user(
    follower_id='4373271c-5141-433e-b868-5f1a2c9174f1',
    following_id='1ef19920-4247-46aa-95ca-85abda317c7d'
)
# Output: User 4373271c-5141-433e-b868-5f1a2c9174f1 is now following user 1ef19920-4247-46aa-95ca-85abda317c7d.
# Returns: True
```

### unfollow_user

Removes a follow relationship between two users.

```python
def unfollow_user(self, follower_id, following_id)
```

**Parameters:**
- `follower_id` (str): UUID of the user who is unfollowing
- `following_id` (str): UUID of the user being unfollowed

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
result = dbm.unfollow_user(
    follower_id='4373271c-5141-433e-b868-5f1a2c9174f1',
    following_id='1ef19920-4247-46aa-95ca-85abda317c7d'
)
# Output: User 4373271c-5141-433e-b868-5f1a2c9174f1 has unfollowed user 1ef19920-4247-46aa-95ca-85abda317c7d.
# Returns: True
```

### get_followers

Gets all users who follow a specific user.

```python
def get_followers(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- List of tuples containing follower information, or None if an error occurs. Each tuple contains:
  - `id` (str): UUID of the follower
  - `name` (str): Name of the follower
  - `profile_picture_url` (str): S3 key for the follower's profile picture

**Example:**
```python
followers = dbm.get_followers(user_id='4373271c-5141-433e-b868-5f1a2c9174f1')
# Returns: [('10fbd641-26ac-46af-9e69-56b429dfdf4b', 'Jessica Russell', None)]
```

### get_following

Gets all users that a specific user follows.

```python
def get_following(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- List of tuples containing following information, or None if an error occurs. Each tuple contains:
  - `id` (str): UUID of the followed user
  - `name` (str): Name of the followed user
  - `profile_picture_url` (str): S3 key for the followed user's profile picture

**Example:**
```python
following = dbm.get_following(user_id='10fbd641-26ac-46af-9e69-56b429dfdf4b')
# Returns: [('4373271c-5141-433e-b868-5f1a2c9174f1', 'Aaryan Nagpal', None)]
```

### is_following

Checks if one user is following another.

```python
def is_following(self, follower_id, following_id)
```

**Parameters:**
- `follower_id` (str): UUID of the potential follower
- `following_id` (str): UUID of the potentially followed user

**Returns:**
- `bool`: True if following, False otherwise

## Feed Management

### get_workout_feed

Retrieves workout feed items from users that the specified user follows.

```python
def get_workout_feed(self, user_id, limit=20, offset=0, include_viewed=False)
```

**Parameters:**
- `user_id` (str): UUID of the user viewing the feed
- `limit` (int, optional): Maximum number of items to return (default: 20)
- `offset` (int, optional): Number of items to skip (for pagination)
- `include_viewed` (bool, optional): Whether to include already viewed workouts

**Returns:**
- List of tuples containing feed information, or None if an error occurs

**Example:**
```python
results = dbm.get_workout_feed(user_id='1ef19920-4247-46aa-95ca-85abda317c7d')
# Returns: List of workout feed items from followed users, sorted by date
```

### mark_workout_viewed

Marks a workout as viewed by a user.

```python
def mark_workout_viewed(self, workout_id, viewer_id)
```

**Parameters:**
- `workout_id` (str): UUID of the workout
- `viewer_id` (str): UUID of the user viewing the workout

**Returns:**
- `bool`: True if successful, False otherwise

**Example:**
```python
dbm.mark_workout_viewed(
    workout_id="5e8987a4-8164-4120-99d8-2cb13de8b98c",
    viewer_id="1ef19920-4247-46aa-95ca-85abda317c7d"
)
# Returns: True and removes this workout from future feed queries
```

## ProfilePictureHandler

The `ProfilePictureHandler` class provides a high-level interface for managing user profile pictures, combining S3 storage and database operations.

### Initialization

```python
from database_manager import ProfilePictureHandler
profile_handler = ProfilePictureHandler()
```

### Methods

#### upload_profile_picture
Uploads a profile picture for a user.

```python
def upload_profile_picture(self, user_id, image_data, content_type)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `image_data` (bytes): Binary image data
- `content_type` (str): MIME type of the image (e.g., "image/jpeg")

**Returns:**
- `bool`: True if successful, False otherwise

#### get_profile_picture
Retrieves a user's profile picture data.

```python
def get_profile_picture(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- Tuple of `(image_data, content_type)`, or `(None, None)` if not found

#### get_profile_picture_url
Generates a presigned URL for a user's profile picture.

```python
def get_profile_picture_url(self, user_id, expiration=3600)
```

**Parameters:**
- `user_id` (str): UUID of the user
- `expiration` (int, optional): URL expiration time in seconds (default: 1 hour)

**Returns:**
- `str`: Presigned URL for the profile picture, or None if not found

#### delete_profile_picture
Deletes a user's profile picture.

```python
def delete_profile_picture(self, user_id)
```

**Parameters:**
- `user_id` (str): UUID of the user

**Returns:**
- `bool`: True if successful, False otherwise

## Lower-Level Components (For Development Reference Only)

The following components are used internally by the `DatabaseManager` and `ProfilePictureHandler` classes and should not be directly accessed by the middle layer.

### S3Manager

The `S3Manager` class handles interactions with Amazon S3 for storing and retrieving profile pictures.

**Key Methods:**
- `upload_profile_picture(user_id, file_data, content_type)`: Uploads an image to S3
- `get_profile_picture_url(s3_key, expiration)`: Generates a presigned URL for an S3 object
- `get_profile_picture_data(s3_key)`: Retrieves image data from S3
- `delete_profile_picture(s3_key)`: Deletes an image from S3

### DatabaseConnector

The `DatabaseConnector` class manages the connection to the PostgreSQL database.

**Key Methods:**
- `connect()`: Establishes a connection to the database
- `execute_query(query, params, commit, fetch)`: Executes a SQL query with parameters
- `close()`: Closes the database connection

The `DatabaseConnector` handles connection management, query execution, and error handling for database operations.