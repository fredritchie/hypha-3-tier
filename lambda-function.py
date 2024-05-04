import json
import boto3

def lambda_handler(event, context):
    # Extract first name and last name from the event payload
    first_name = event['firstName']
    last_name = event['lastName']
    
    # Initialize DynamoDB client
    dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
    table_name = 'webapp'
    table = dynamodb.Table(table_name)
    
    try:
        # Insert data into DynamoDB table
        response = table.put_item(
            Item={
                'firstName': first_name,
                'lastName': last_name
            }
        )
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps('Data inserted successfully')
        }
    except Exception as e:
        # Return error response
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
