import os
import json
import boto3

dynamodb = boto3.client("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]

def increment(event, context):
    try:
        response = dynamodb.update_item(
            TableName=TABLE_NAME,
            Key={"id": {"S": "main"}},
            UpdateExpression="ADD visitor_count :inc",
            ExpressionAttributeValues={":inc": {"N": "1"}},
            ReturnValues="UPDATED_NEW"
        )
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }

def get_count(event, context):
    try:
        response = dynamodb.get_item(
            TableName=TABLE_NAME,
            Key={"id": {"S": "main"}},
        )
        count = int(response["Item"]["visitor_count"]["N"])
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"count": count})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }