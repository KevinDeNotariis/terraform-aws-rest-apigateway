"""Authorizer for websocekt api gateway."""  # noqa: INP001

import os
import re

import cognitojwt
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEventV2
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_xray_sdk.core import patch_all

patch_all()

tracer = Tracer()
logger = Logger()

REGION = os.environ["AWS_REGION"]
USER_POOL_ID = os.environ["USER_POOL_ID"]
APP_CLIENT_ID = os.environ["APP_CLIENT_ID"]

UNUATHORIZED = "Unauthorized"


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def lambda_handler(event: dict, _: LambdaContext) -> dict:
    """Authorize a JWT token from Cognito."""
    logger.debug("authorizer event=%s", event)
    event: APIGatewayProxyEventV2 = APIGatewayProxyEventV2(event)

    # Retrieve request parameters from the Lambda function input:
    headers = {key.lower(): value for key, value in event.headers.items()}
    query_string_parameters = event.query_string_parameters
    stage_variables = event.stage_variables
    request_context = event.request_context
    logger.info(
        "query_string_parameters=%s, stage_variables=%s, request_context=%s",
        query_string_parameters,
        stage_variables,
        request_context,
    )

    # Parse the input for the parameter values
    tmp = event.raw_event["methodArn"].split(":")
    api_gateway_arn_tmp = tmp[5].split("/")
    aws_account_id = tmp[4]
    region = tmp[3]
    api_id = api_gateway_arn_tmp[0]
    stage = api_gateway_arn_tmp[1]

    if "authorization" not in headers:
        raise Exception(UNUATHORIZED)
    if not re.match(r"^Bearer: .*$", headers["authorization"]):
        raise Exception(UNUATHORIZED)

    # Authorization = Bearer: e.....
    cognito_jwt = headers["authorization"].split(" ")[1]

    try:
        verified_claims: dict = cognitojwt.decode(
            cognito_jwt,
            REGION,
            USER_POOL_ID,
            app_client_id=APP_CLIENT_ID,
            testmode=False,
        )
    except Exception:  # noqa: BLE001
        raise Exception(UNUATHORIZED)  # noqa: B904

    given_name = verified_claims["given_name"]
    family_name = verified_claims["family_name"]
    username = verified_claims["cognito:username"]
    user_id = verified_claims["custom:id"]

    logger.info({"given_name": given_name, "family_name": family_name, "username": username, "user_id": user_id})
    response = generate_allow(username, event.raw_event["methodArn"])
    response["context"] = {
        "given_name": given_name,
        "family_name": family_name,
        "username": username,
        "user_id": user_id,
    }
    logger.debug(response)

    return response


def generate_policy(principal_id: str, effect: str, resource: str) -> dict:
    """Generate a policy for the given principal id."""
    auth_response = {}
    auth_response["principalId"] = principal_id
    if effect and resource:
        policy_document = {}
        policy_document["Version"] = "2012-10-17"
        policy_document["Statement"] = []
        statement_one = {}
        statement_one["Action"] = "execute-api:Invoke"
        statement_one["Effect"] = effect
        statement_one["Resource"] = resource
        policy_document["Statement"] = [statement_one]
        auth_response["policyDocument"] = policy_document

    return auth_response


def generate_allow(principal_id: str, resource: str) -> dict:
    """Generate an Allow policy."""
    return generate_policy(principal_id, "Allow", resource)


def generate_deny(principal_id: str, resource: str) -> dict:
    """Generate a Deny policy."""
    return generate_policy(principal_id, "Deny", resource)
