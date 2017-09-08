/**
 * @license
 * The MIT License (MIT)
 * Copyright 2015 Government of Canada
 *
 * @author
 * Ian Boyes
 *
 * @exports Isolate
 */

import React, { PropTypes } from "react";
import URI from "urijs";
import { capitalize, find } from "lodash";
import { connect } from "react-redux";
import { Badge, Label, Panel, Table, ListGroup } from "react-bootstrap";

import {
    showEditIsolate,
    showRemoveIsolate,
    showAddSequence,
    showEditSequence,
    showRemoveSequence
} from "../../actions";
import { formatIsolateName } from "virtool/js/utils";
import { Icon, ListGroupItem } from "virtool/js/components/Base";
import { followDownload } from "virtool/js/utils";
import Sequence from "./Sequence";
import EditIsolate from "./EditIsolate";
import RemoveIsolate from "./RemoveIsolate";
import AddSequence from "./AddSequence";
import EditSequence from "./EditSequence";
import RemoveSequence from "./RemoveSequence";

const IsolateDetail = (props) => {

    const activeIsolateId = props.match.params.isolateId;
    const isolate = find(props.isolates, {id: activeIsolateId});
    const isolateName = formatIsolateName(isolate);

    const activeAccession = props.match.params.accession;

    const defaultIsolateLabel = (
        <Label bsStyle="info" style={{visibility: props.default ? "visible": "hidden"}}>
            <Icon name="star" /> Default Isolate
        </Label>
    );

    let sequenceComponents = isolate.sequences.map(sequence =>
        <Sequence
            key={sequence.id}
            active={sequence.accession === activeAccession}
            showEditSequence={props.showEditSequence}
            showRemoveSequence={props.showRemoveSequence}
            {...sequence}
        />
    );

    if (!sequenceComponents.length) {
        sequenceComponents = (
            <ListGroupItem className="text-center">
                <Icon name="info" /> No sequences added
            </ListGroupItem>
        );
    }

    let modifyIcons = (
        <span>
            <Icon
                name="pencil"
                bsStyle="warning"
                tip="Edit Name"
                onClick={props.showEditIsolate}
                style={{paddingLeft: "7px"}}
            />

            <Icon
                name="remove"
                bsStyle="danger"
                tip="Remove Isolate"
                onClick={props.showRemoveIsolate}
                style={{paddingLeft: "3px"}}
            />

            <Icon
                name="download"
                tip="Download FASTA"
                onClick={() => followDownload(`/download/viruses/${props.virusId}/isolates/${isolate.id}`)}
                style={{paddingLeft: "3px"}}
            />
        </span>
    );

    const nextURI = URI(props.location.pathname + props.location.search);

    if (props.isolates.length) {
        nextURI.segment(3, props.isolates[0].id);
    } else {
        nextURI.segment(3, "");
    }

    return (
        <div>
            <EditIsolate
                virusId={props.virusId}
                isolateId={isolate.id}
                sourceType={isolate.source_type}
                sourceName={isolate.source_name}
            />

            <RemoveIsolate
                virusId={props.virusId}
                isolateId={isolate.id}
                isolateName={isolateName}
                onSuccess={() => props.history.push(nextURI.toString())}
            />

            <AddSequence
                virusId={props.virusId}
                isolateId={isolate.id}
            />

            <EditSequence
                virusId={props.virusId}
                isolateId={isolate.id}
            />

            <RemoveSequence
                virusId={props.virusId}
                isolateId={isolate.id}
                isolateName={isolateName}
            />

            <Panel>
                <ListGroup fill>
                    <ListGroupItem>
                        <h5 style={{display: "flex", alignItems: "center", marginBottom: "15px"}}>
                            <strong style={{flex: "1 0 auto"}}>{isolateName}</strong>
                            {defaultIsolateLabel}
                            {modifyIcons}
                        </h5>

                        <Table bordered>
                            <tbody>
                                <tr>
                                    <th className="col-md-3">Name</th>
                                    <td className="col-md-9">{isolateName}</td>
                                </tr>
                                <tr>
                                    <th>Source Type</th>
                                    <td>{capitalize(isolate.source_type)}</td>
                                </tr>
                                <tr>
                                    <th>Source Name</th>
                                    <td>{isolate.source_name}</td>
                                </tr>
                                <tr>
                                    <th>Unique ID</th>
                                    <td>{isolate.id}</td>
                                </tr>
                            </tbody>
                        </Table>

                        <div style={{marginTop: "45px", display: "flex", alignItems: "center"}}>
                            <strong style={{flex: "0 1 auto"}}>Sequences</strong>
                            <span style={{flex: "1 0 auto", marginLeft: "5px"}}>
                                <Badge>{isolate.sequences.length}</Badge>
                            </span>
                            <Icon
                                name="new-entry"
                                bsStyle="primary"
                                tip="Add Sequence"
                                onClick={() => props.showAddSequence()}
                                pullRight
                            />
                        </div>
                    </ListGroupItem>

                    {sequenceComponents}
                </ListGroup>
            </Panel>
        </div>
    );
};

IsolateDetail.propTypes = {
    match: PropTypes.object,
    history: PropTypes.object,
    location: PropTypes.object,

    virusId: PropTypes.string,
    default: PropTypes.string,
    isolates: PropTypes.arrayOf(PropTypes.object),

    allowedSourceTypes: PropTypes.arrayOf(PropTypes.string),
    restrictSourceTypes: PropTypes.bool,
    showEditIsolate: PropTypes.func,
    showRemoveIsolate: PropTypes.func,
    showAddSequence: PropTypes.func,
    showEditSequence: PropTypes.func,
    showRemoveSequence: PropTypes.func

};

const mapStateToProps = (state) => {
    return {
        isolates: state.viruses.detail.isolates,
        virusId: state.viruses.detail.id,
        editing: state.viruses.editingIsolate,
        editingSequence: state.viruses.editSequence,
        allowedSourceTypes: state.settings.data.allowed_source_types,
        restrictSourceTypes: state.settings.data.restrict_source_types
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        showEditIsolate: (virusId, isolateId, sourceType, sourceName) => {
            dispatch(showEditIsolate(virusId, isolateId, sourceType, sourceName));
        },

        showRemoveIsolate: () => {
            dispatch(showRemoveIsolate());
        },

        showAddSequence: () => {
            dispatch(showAddSequence());
        },

        showEditSequence: (sequenceId) => {
            dispatch(showEditSequence(sequenceId));
        },

        showRemoveSequence: (sequenceId) => {
            dispatch(showRemoveSequence(sequenceId));
        },
    };
};

const Container = connect(mapStateToProps, mapDispatchToProps)(IsolateDetail);

export default Container;