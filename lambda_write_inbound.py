import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    outbound_bucket = os.environ['OUTBOUND_BUCKET']
    inbound_bucket = os.environ['INBOUND_BUCKET']
    key = 'sample.txt'
    try:
        obj = s3.get_object(Bucket=outbound_bucket, Key=key)
        content = obj['Body'].read()
        s3.put_object(Bucket=inbound_bucket, Key=key, Body=content)
        return {'statusCode': 200, 'body': 'File copied from outbound to inbound bucket'}
    except Exception as e:
        return {'statusCode': 500, 'body': str(e)}