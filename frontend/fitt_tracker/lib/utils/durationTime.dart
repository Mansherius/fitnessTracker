// Converts a Duration object into an integer (total seconds)
int durationToSeconds(Duration duration) {
  return duration.inSeconds;
}

// Converts an integer (total seconds) back into a Duration object
Duration secondsToDuration(int seconds) {
  return Duration(seconds: seconds);
}