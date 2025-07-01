import os
import json
import boto3

dynamodb = boto3.client("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]

def handler(event, context):
    try:
        response = dynamodb.update_item(
            TableName=TABLE_NAME,
            Key={"id": {"S": "main"}},
            UpdateExpression="ADD visitor_count :inc",
            ExpressionAttributeValues={":inc": {"N": "1"}},
            ReturnValues="UPDATED_NEW"
        )
        count = int(response["Attributes"]["visitor_count"]["N"])
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