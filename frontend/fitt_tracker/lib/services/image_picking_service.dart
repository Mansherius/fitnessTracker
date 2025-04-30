import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImagePickingService {
  final String baseUrl = 'http://51.20.171.163:8000';

  /// Uploads a new profile picture for the user
  Future<bool> uploadProfilePicture(String userId, XFile imageFile) async {
  try {
    // Construct the POST request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/$userId/profile-picture'),
    );

    // Add the image file as form data
    request.files.add(await http.MultipartFile.fromPath(
      'file', // This must match the backend's expected form field name
      imageFile.path,
    ));

    // Send the request
    final response = await request.send();

    // Check the response status code
    if (response.statusCode == 201) {
      print('Profile picture uploaded successfully for user $userId.');
      return true; // Indicate success
    } else {
      print('Failed to upload profile picture: ${response.statusCode}');
      return false; // Indicate failure
    }
  } catch (e) {
    print('Error uploading profile picture: $e');
    return false; // Indicate failure
  }
}

  /// Deletes the user's profile picture
  Future<bool> deleteProfilePicture(String userId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/profile-picture'),
    );

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      print('Failed to delete profile picture: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error deleting profile picture: $e');
    return false;
  }
}

  /// Fetches the user's current profile picture URL
  Future<String?> getProfilePictureUrl(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/profile-picture'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] != null && data['url'].startsWith('http')
          ? data['url']
          : '$baseUrl${data['url']}'; // Return the full profile picture URL
    } else {
      print('Failed to fetch profile picture: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching profile picture: $e');
    return null;
  }
}
}