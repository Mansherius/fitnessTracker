# Cloud Computing - Fitness Tracker

This repository contains the source code for the Cloud Computing - Fitness Tracker project—a scalable mobile fitness tracking application designed to log workouts, monitor health metrics, and provide personalized workout recommendations.

## Overview

The project is divided into two main components:
- **Backend:**  
  A modular Django-based backend that provides REST APIs for user management, workout logging, analytics, leaderboards, and workout recommendations. It leverages PostgreSQL for structured data, Redis for caching, and Docker for containerized deployment.
- **Frontend:**  
  A Flutter-based mobile application that serves as the user interface. The app allows users to track their workouts, view analytics, and receive recommendations.

## Folder Structure

```
.
├── LICENSE
├── README.md
├── backend              # Django backend and microservices
├── docker-compose.yaml  # Docker Compose configuration for local development
└── frontend
    └── your_app_name    # Flutter project (created with: flutter create --org com.yourdomain your_app_name)
```

- **backend:** Contains all backend code, including the Django project, APIs, and service layers.
- **frontend:** Contains your Flutter project. This is where you build and manage your mobile app.
- **docker-compose.yaml:** Provides a configuration to orchestrate containers for the backend, database, cache, etc.

## Getting Started

### Prerequisites

- **Flutter:** [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Python & Django:** Ensure Python 3.x is installed and set up for Django development.
- **Docker & Docker Compose:** For containerized development environments.
- **Git:** For version control.

### Setting Up the Backend

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Set up your Python virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Configure your environment variables as needed (e.g., database settings).
4. Run database migrations and start the server:
   ```bash
   python manage.py migrate
   python manage.py runserver
   ```

### Setting Up the Frontend

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Create a new Flutter project (if you haven’t already):
   ```bash
   flutter create --org com.yourdomain your_app_name
   ```
3. Change into the newly created Flutter project folder:
   ```bash
   cd your_app_name
   ```
4. Run the Flutter application:
   ```bash
   flutter run
   ```

### Using Docker Compose

For a unified local development environment, you can use Docker Compose. This will bring up your backend, database, and other related services as defined in the `docker-compose.yaml` file.

Run:
```bash
docker-compose up
```

## Deployment

- **Backend:**  
  The backend is containerized and can be deployed on cloud platforms (e.g., AWS Elastic Beanstalk). Update the environment configurations for production and leverage CI/CD (e.g., GitHub Actions) for automated deployments.
- **Frontend:**  
  Build the Flutter app for release on both Android and iOS using standard Flutter build commands.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a feature branch.
3. Commit your changes with clear messages.
4. Push to your branch and open a pull request for review.

## License

This project is licensed under the terms of the [LICENSE](./LICENSE).

Feel free to modify any sections to better suit your project's specifics.
