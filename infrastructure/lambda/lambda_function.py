import json
import boto3
from decimal import Decimal

def lambda_handler(event, context):
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('cloud_resume_stats')

        # Fetch current view count
        response = table.get_item(Key={'stat': 'view-count'})
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps("Item not found")
            }
        view_count = int(response['Item']['view-count'])  # Convert Decimal to int

        # Increment view count
        view_count += 1

        # Update view count in DynamoDB
        table.put_item(Item={'stat': 'view-count', 'view-count': view_count})

        # Return updated view count
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'view_count': view_count})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }