"""Test endpoint"""

import json
import os
import re

import boto3
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_xray_sdk.core import patch_all

patch_all()

tracer = Tracer()
logger = Logger()
app = APIGatewayRestResolver(strip_prefixes=[re.compile(r"/v1")])


@app.get("/")
@tracer.capture_method
def get_ok() -> dict:
    """Return ok."""
    return {"message": "ok"}


@app.post("/")
@tracer.capture_method
def post_ok() -> dict:
    """Return back what is in the body."""
    body = app.current_event.body

    return {"message": json.dumps(body)}


@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
@tracer.capture_lambda_handler
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    """Route request to the correct meethod."""
    logger.debug(event)
    return app.resolve(event, context)
