from aiohttp import web
from cerberus import Validator
from pymongo import ReturnDocument
from virtool.utils import timestamp
from virtool.handlers.utils import json_response, requires_login, invalid_input
from virtool.users import hash_password, validate_credentials, invalidate_session


async def get_settings(req):
    """
    Get account settings
    
    """
    user_id = req["session"].user_id

    if not user_id:
        return requires_login()

    document = await req.app["db"].users.find_one({"_id": user_id})

    return json_response(document["settings"])


async def update_settings(req):
    """
    Update account settings.

    """
    user_id = req["session"].user_id

    if not user_id:
        return requires_login()

    data = await req.json()

    v = Validator({
        "show_ids": {
            "type": "boolean",
            "required": False
        },
        "show_versions": {
            "type": "boolean",
            "required": False
        },
        "quick_analyze_algorithm": {
            "type": "boolean",
            "required": False
        },
        "skip_quick_analyze_dialog": {
            "type": "string",
            "required": False
        }
    })

    if not v(data):
        return invalid_input(v.errors)

    settings = (await req.app["db"].users.find_one({"_id": user_id}))["settings"]

    settings.update(data)

    document = await req.app["db"].users.find_one_and_update({"_id": user_id}, {
        "$set": {
            "settings": settings
        }
    }, return_document=ReturnDocument.AFTER)

    return json_response(document["settings"])


async def change_password(req):
    """
    Allows a user change their own password.

    """
    user_id = req["session"].user_id

    if not user_id:
        return requires_login()

    data = await req.json()

    v = Validator({
        "old_password": {"type": "string", "required": True},
        "new_password": {"type": "string", "required": True}
    })

    if not v(data):
        return invalid_input(v.errors)

    data = await req.json()

    # Will evaluate true if the passed username and password are correct.
    if not await validate_credentials(req.app["db"], user_id, data["old_password"]):
        return json_response({"message": "Invalid credentials"}, status=400)

    # Salt and hash the new password
    hashed = hash_password(data["new_password"])

    last_password_change = timestamp()

    # Update the user document. Remove all sessions so those clients will have to authenticate with the new
    # password.
    await req.app["db"].users.update({"_id": user_id}, {
        "$set": {
            "password": hashed,
            "invalidate_sessions": False,
            "last_password_change": last_password_change,
            "force_reset": False
        }
    })

    return json_response({"timestamp": last_password_change})


async def logout(req):
    requesting_token = None

    await invalidate_session(req.app["db"], requesting_token, logout=True)

    return json_response({"logout": True})
