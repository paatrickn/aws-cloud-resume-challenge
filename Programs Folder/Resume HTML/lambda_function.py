import json
import boto3
import simplejson

# dynamodb = boto3.resource('dynamodb')
# table = dynamodb.Table('cloud_resume_stats')

# def response (message, status_code):
#     headers = {
#         'Content-Type': 'application/json',
#         'Access-Control-Allow-Origin': '*',
#         'Access-Control-Allow-Methods':"OPTIONS, GET, PUT",
#         'Access-Control-Allow-Headers': '*'
#     }
#     return {
#         'statusCode': str(status_code),
#         'body': json.dumps(message),
#         'statusCode': 200,
#         'headers': headers
#     }




def lambda_handler(event, context):

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('cloud_resume_stats')

    response = table.get_item(Key={
      'stat':'view-count'
    })
    
    view_count = response['Item']['view-count']
    view_count = view_count + 1
    print(view_count)
    
    response = table.put_item(Item={
        'stat':'view-count',
        'view-count': view_count
    })

    # headers = {
    #     'Content-Type': 'application/json',
    #     'Access-Control-Allow-Origin': '*',
    #     'Access-Control-Allow-Headers': '*'
    # }
    return view_count


    # return {
    #     # 'statusCode': 200,
    #     # 'headers': headers,

    #     # 'body': json.dumps({'view_count': view_count})
    #     'body': simplejson.dumps({'view_count'})
    #     # 'body': simplejson.dumps({'view_count': view_count})
    
    #      }
