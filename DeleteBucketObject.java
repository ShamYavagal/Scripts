package s3;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

class DeleteBucketObject {
	
	public static void main(String[] args) {
		final BasicAWSCredentials awsCreds = new BasicAWSCredentials(Credentials.access_key_id, Credentials.secret_access_key);
		
		
		/* @SuppressWarnings("deprecation")
		AmazonS3 s3 = new AmazonS3Client(awsCreds); */
		
	     /* Region usEast1 = Region.getRegion(Regions.US_EAST_1);
			s3.setRegion(usEast1); */
		
		AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(awsCreds))
                .withRegion(Regions.US_EAST_1)
                .build();
						
		String bucket_name = "bucket_name";
		String object_key = "test1.txt";
		
		try {
			s3.deleteObject(bucket_name, object_key);
		} catch (AmazonServiceException e) {
			System.err.println(e.getErrorMessage());
			System.exit(1);
		}
		
    }

}
