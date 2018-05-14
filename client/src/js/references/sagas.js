import { LOCATION_CHANGE, push } from "react-router-redux";
import { takeLatest, throttle, put, takeEvery } from "redux-saga/effects";

import * as referenceAPI from "./api";
import { apiCall, apiFind, setPending } from "../sagaUtils";
import {
    CREATE_REFERENCE,
    GET_REFERENCE,
    LIST_REFERENCES,
    REMOVE_REFERENCE,
    IMPORT_REFERENCE
} from "../actionTypes";

export function* listReferences (action) {
    yield apiFind("/refs", referenceAPI.list, action, LIST_REFERENCES);
}

export function* getReference (action) {
    yield apiCall(referenceAPI.get, action, GET_REFERENCE);
}

export function* createReference (action) {
    yield apiCall(referenceAPI.create, action, CREATE_REFERENCE);
    yield put(push({state: {createReference: false}}));
}

export function* removeReference (action) {
    yield setPending(apiCall(referenceAPI.remove, action, REMOVE_REFERENCE));
    yield put(push("/refs"));
}

export function* importReference (action) {
    yield setPending(apiCall(referenceAPI.importReference, action, IMPORT_REFERENCE));
    yield put(push({state: {importReference: false}}));
}

export function* watchReferences () {
    yield throttle(300, CREATE_REFERENCE.REQUESTED, createReference);
    yield takeLatest(GET_REFERENCE.REQUESTED, getReference);
    yield throttle(300, LOCATION_CHANGE, listReferences);
    yield takeEvery(REMOVE_REFERENCE.REQUESTED, removeReference);
    yield takeLatest(IMPORT_REFERENCE.REQUESTED, importReference);
}
