import json

def handler(event, context):
    # You can replace this logic with actual user registration logic
    return {
        'statusCode': 200,
        'body': json.dumps('User registration successful!')
    }