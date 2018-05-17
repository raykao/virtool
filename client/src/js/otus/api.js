import Request from "superagent";

export const find = () => (
    Request.get(`/api${window.location.pathname}${window.location.search}`)
);

export const listNames = ({ refId }) => (
    Request.get(`/api/refs/${refId}/otus?names=true`)
);

export const get = ({ otuId }) => (
    Request.get(`/api/otus/${otuId}`)
);

export const getHistory = ({ refId, otuId }) => (
    Request.get(`/api/refs/${refId}/otus/${otuId}/history`)
);

export const getGenbank = (accession) => (
    Request.get(`/api/genbank/${accession}`)
);

export const create = ({ refId, name, abbreviation }) => (
    Request.post(`/api/refs/${refId}/otus`)
        .send({
            name,
            abbreviation
        })
);

export const edit = ({ otuId, name, abbreviation, schema }) => (
    Request.patch(`/api/otus/${otuId}`)
        .send({
            name,
            abbreviation,
            schema
        })
);

export const remove = ({ otuId }) => (
    Request.delete(`/api/otus/${otuId}`)
);

export const addIsolate = ({ otuId, sourceType, sourceName }) => (
    Request.post(`/api/otus/${otuId}/isolates`)
        .send({
            source_type: sourceType,
            source_name: sourceName
        })
);

export const editIsolate = ({ otuId, isolateId, sourceType, sourceName }) => (
    Request.patch(`/api/otus/${otuId}/isolates/${isolateId}`)
        .send({
            source_type: sourceType,
            source_name: sourceName
        })
);

export const setIsolateAsDefault = ({ otuId, isolateId }) => (
    Request.put(`/api/otus/${otuId}/isolates/${isolateId}/default`)
);

export const removeIsolate = ({ otuId, isolateId }) => (
    Request.delete(`/api/otus/${otuId}/isolates/${isolateId}`)
);

export const addSequence = ({ otuId, isolateId, sequenceId, definition, host, sequence, segment }) => (
    Request.post(`/api/otus/${otuId}/isolates/${isolateId}/sequences`)
        .send({
            id: sequenceId,
            definition,
            host,
            sequence,
            segment
        })
);

export const editSequence = ({ otuId, isolateId, sequenceId, definition, host, sequence, segment }) => (
    Request.patch(`/api/otus/${otuId}/isolates/${isolateId}/sequences/${sequenceId}`)
        .send({
            definition,
            host,
            sequence,
            segment
        })
);

export const removeSequence = ({ otuId, isolateId, sequenceId }) => (
    Request.delete(`/api/otus/${otuId}/isolates/${isolateId}/sequences/${sequenceId}`)
);

export const revert = ({ refId, otuId, version }) => (
    Request.delete(`/api/refs/${refId}/history/${otuId}.${version}`)
);
