import boto3
import uuid
import io
from botocore.exceptions import ClientError
from config import AWS_CONFIG

class S3Manager:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=AWS_CONFIG['aws_access_key_id'],
            aws_secret_access_key=AWS_CONFIG['aws_secret_access_key'],
            region_name=AWS_CONFIG['region_name']
        )
        self.bucket_name = AWS_CONFIG['bucket_name']
    
    def upload_profile_picture(self, user_id, file_data, content_type):
        """
        Upload a user's profile picture to S3 as a private object
        Returns the S3 key of the uploaded image
        """
        try:
            # Generate a unique filename using user_id and uuid
            filename = f"profile_pictures/{user_id}/{uuid.uuid4()}"
            
            # Upload the file to S3 as private (default)
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=filename,
                Body=file_data,
                ContentType=content_type
            )
            
            # Return the S3 key (instead of a URL)
            return filename
        
        except ClientError as e:
            print(f"Error uploading to S3: {e}")
            return None
    
    def get_profile_picture_url(self, s3_key, expiration=3600):
        """
        Generate a presigned URL for a user's profile picture
        This URL will expire after the specified time (default: 1 hour)
        """
        try:
            presigned_url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={
                    'Bucket': self.bucket_name,
                    'Key': s3_key
                },
                ExpiresIn=expiration
            )
            return presigned_url
        
        except ClientError as e:
            print(f"Error generating presigned URL: {e}")
            return None
    
    def get_profile_picture_data(self, s3_key):
        """
        Retrieve the actual image data for a profile picture
        Returns a tuple of (image_data, content_type) or (None, None) if error
        """
        try:
            response = self.s3_client.get_object(
                Bucket=self.bucket_name,
                Key=s3_key
            )
            
            # Get the image data and content type
            image_data = response['Body'].read()
            content_type = response.get('ContentType', 'application/octet-stream')
            
            return image_data, content_type
        
        except ClientError as e:
            print(f"Error retrieving image from S3: {e}")
            return None, None
    
    def delete_profile_picture(self, s3_key):
        """
        Delete a profile picture from S3 using its key
        """
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=s3_key
            )
            return True
        
        except ClientError as e:
            print(f"Error deleting from S3: {e}")
            return False