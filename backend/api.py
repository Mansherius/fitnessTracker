from flask import Flask, request, jsonify
from flask_cors import CORS
from database_manager import DatabaseManager, ProfilePictureHandler
from s3_manager import S3Manager

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests (e.g., from Flutter)

db_manager = DatabaseManager()
picture_handler = ProfilePictureHandler()
s3_manager = S3Manager()

# ------------------ User Management ------------------

#add user from USERS

@app.route('/users', methods=['POST'])  
def add_user():
    data = request.json
    try:
        db_manager.add_user(
            name=data['name'],
            email=data['email'],
            password_hash=data['password_hash'],
            age=data['age'],
            gender=data['gender'],
            fitness_level=data.get('fitness_level'),
            profile_picture_url=data.get('profile_picture_url')
        )
        return jsonify({"message": "User added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route('/users/<user_id>', methods=['GET'])
def get_user_profile(user_id):
    try:
        user = db_manager.get_user_profile(user_id)
        if user:
            return jsonify(user), 200
        return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 400

    
@app.route('/login', methods=['POST'])
def user_login():
    data = request.json
    try:
        user_id = db_manager.user_login(
            email=data['email'],
            password_hash=data['password_hash']
        )
        if user_id:
            return jsonify({"message": "Login successful", "user_id": user_id}), 200
        return jsonify({"error": "Invalid email or password"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>', methods=['PUT'])
def update_user_profile(user_id):
    data = request.json
    try:
        db_manager.update_user_profile(
            user_id=user_id,
            name=data.get('name'),
            email=data.get('email'),
            fitness_level=data.get('fitness_level')
        )
        return jsonify({"message": "User profile updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>', methods=['DELETE'])
def delete_user(user_id):
    try:
        db_manager.delete_user(user_id)
        return jsonify({"message": "User deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ------------------ Profile Picture ------------------

@app.route('/users/<user_id>/profile-picture', methods=['POST'])
def upload_profile_picture(user_id):
    try:
        file = request.files['file']
        content_type = file.content_type
        image_data = file.read()
        url = picture_handler.upload_profile_picture(user_id, image_data, content_type)
        return jsonify({"url": url}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>/profile-picture', methods=['GET'])
def get_profile_picture_url(user_id):
    try:
        url = picture_handler.get_profile_picture_url(user_id)
        if url:
            return jsonify({"url": url}), 200
        return jsonify({"error": "Profile picture not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>/profile-picture', methods=['DELETE'])
def delete_profile_picture(user_id):
    try:
        success = picture_handler.delete_profile_picture(user_id)

        if success:
            return jsonify({"message": "Profile picture deleted"}), 200
        return jsonify({"error": "Failed to delete profile picture"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ------------------ Workouts ------------------

@app.route('/workouts', methods=['POST'])
def start_workout():
    data = request.json
    try:
        workout_id = db_manager.start_workout(
            user_id=data['user_id'],
            date=data['date'],
            name=data.get('name'),
            notes=data.get('notes'),
            routine=data.get('routine',"0")
        )
        return jsonify({"message": "Workout added successfully", "workout_id": workout_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/workouts/<user_id>', methods=['GET'])
def get_user_workouts(user_id):
    try:
        workouts = db_manager.get_user_workouts(user_id)
        return jsonify(workouts), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/workouts/<workout_id>', methods=['PATCH'])
def update_workout(workout_id):
    data = request.json
    try:
        success = db_manager.update_workout(
            workout_id=workout_id,
            date=data.get('date'),
            name=data.get('name'),
            notes=data.get('notes'),
            volume=data.get('volume'),
            duration=data.get('duration')
        )
        if success:
            return jsonify({"message": "Workout updated successfully"}), 200
        return jsonify({"error": "No updates provided"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/workouts/<workout_id>', methods=['DELETE'])
def delete_workout(workout_id):
    try:
        success = db_manager.delete_workout(workout_id)
        if success:
            return jsonify({"message": "Workout deleted successfully"}), 200
        return jsonify({"error": "Failed to delete workout"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# get list of exercises from WORKOUTS    
    
@app.route('/workouts/<workout_id>/exercises', methods=['GET'])
def get_workout_exercises(workout_id):
    try:
        exercises = db_manager.get_workout_exercises(workout_id)
        return jsonify(exercises), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    
# get workout details from WORKOUTS
    
@app.route('/workouts/details/<workout_id>', methods=['GET'])
def get_workout_details(workout_id):
    try:
        workout = db_manager.get_workout_details(workout_id)
        if workout:
            return jsonify(workout), 200
        return jsonify({"error": "Workout not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>/routines', methods=['GET'])
def get_user_routines(user_id):
    try:
        routines = db_manager.get_user_routines(user_id)
        if routines is not None:
            return jsonify(routines), 200
        return jsonify({"error": "Failed to fetch routines"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ------------------ Exercises ------------------

#get list of exercises from EXERCISES

@app.route('/exercises', methods=['GET'])
def get_exercise_list():
    category = request.args.get('category')
    try:
        exercises = db_manager.get_exercise_list(category)
        return jsonify(exercises), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

#add an exercise in a workout 

@app.route('/exercises', methods=['POST'])
def add_exercise():
    data = request.json
    try:
        exercise_id = db_manager.add_exercise(
            workout_id=data['workout_id'],
            exercise=data['exercise'],
            sets=data['sets'],
            reps=data['reps'],
            weight=data['weight']
        )
        if exercise_id:
            return jsonify({"message": "Exercise logged", "exercise_id": exercise_id}), 201
        return jsonify({"error": "Failed to log exercise"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

#update exercise in a workout 
@app.route('/exercises/<exercise_id>', methods=['PUT'])
def update_exercise(exercise_id):
    data = request.json
    try:
        success = db_manager.update_exercise(
            exercise_id=exercise_id,
            exercise=data.get('exercise'),
            sets=data.get('sets'),
            reps=data.get('reps'),
            weight=data.get('weight')
        )
        if success:
            return jsonify({"message": "Exercise updated"}), 200
        return jsonify({"error": "No updates provided or update failed"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    


@app.route('/exercises/<exercise_id>', methods=['DELETE'])
def delete_exercise(exercise_id):
    try:
        success = db_manager.delete_exercise(exercise_id)
        if success:
            return jsonify({"message": "Exercise deleted"}), 200
        return jsonify({"error": "Failed to delete exercise"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    



# ------------------ Measurements ------------------

@app.route('/measurements', methods=['POST'])
def add_measurement():
    data = request.json
    try:
        db_manager.add_measurement(
            user_id=data['user_id'],
            weight=data['weight'],
            bmi=data.get('bmi'),
            body_fat_percentage=data.get('body_fat_percentage'),
            muscle_mass=data.get('muscle_mass'),
            date=data['date']
        )
        return jsonify({"message": "Measurement added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/measurements/<user_id>', methods=['GET'])
def get_measurements(user_id):
    try:
        measurements = db_manager.get_measurements(user_id)
        return jsonify(measurements), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/measurements/<measurement_id>', methods=['PUT'])
def update_measurement(measurement_id):
    data = request.json
    try:
        db_manager.update_measurement(
            measurement_id=measurement_id,
            weight=data.get('weight'),
            bmi=data.get('bmi'),
            body_fat_percentage=data.get('body_fat_percentage'),
            muscle_mass=data.get('muscle_mass')
        )
        return jsonify({"message": "Measurement updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/measurements/<measurement_id>', methods=['DELETE'])
def delete_measurement(measurement_id):
    try:
        db_manager.delete_measurement(measurement_id)
        return jsonify({"message": "Measurement deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# ------------------ Social Features ------------------

@app.route('/follow', methods=['POST'])
def follow_user():
    data = request.json
    try:
        db_manager.follow_user(data['follower_id'], data['followee_id'])
        return jsonify({"message": "Followed user"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/unfollow', methods=['POST'])
def unfollow_user():
    data = request.json
    try:
        db_manager.unfollow_user(data['follower_id'], data['followee_id'])
        return jsonify({"message": "Unfollowed user"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>/followers', methods=['GET'])
def get_followers(user_id):
    try:
        return jsonify(db_manager.get_followers(user_id)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/users/<user_id>/following', methods=['GET'])
def get_following(user_id):
    try:
        return jsonify(db_manager.get_following(user_id)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/is-following', methods=['POST'])
def is_following():
    data = request.json
    try:
        result = db_manager.is_following(data['follower_id'], data['followee_id'])
        return jsonify({"is_following": result}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ------------------ Workout Feed ------------------

@app.route('/feed/<user_id>', methods=['GET'])
def get_workout_feed(user_id):
    try:
        return jsonify(db_manager.get_workout_feed(user_id)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/feed/viewed', methods=['POST'])
def mark_workout_viewed():
    data = request.json
    try:
        db_manager.mark_workout_viewed(data['viewer_id'], data['workout_id'])
        return jsonify({"message": "Marked as viewed"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# ------------------ Leaderboard ------------------

@app.route('/leaderboard', methods=['GET'])
def get_leaderboard():
    limit = request.args.get('limit', 10, type=int)
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    try:
        leaderboard = db_manager.get_leaderboard(limit, start_date, end_date)
        return jsonify(leaderboard), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/leaderboard/<user_id>/rank', methods=['GET'])
def get_user_ranking(user_id):
    try:
        rank = db_manager.get_user_ranking(user_id)
        if rank is not None:
            return jsonify({"rank": rank}), 200
        return jsonify({"error": "User not found in leaderboard"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/leaderboard/update', methods=['POST'])
def update_leaderboard():
    try:
        db_manager.update_leaderboard()
        return jsonify({"message": "Leaderboard updated"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ------------------ App Run ------------------

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
