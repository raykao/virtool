/**
 *
 *
 * @copyright 2017 Government of Canada
 * @license MIT
 * @author igboyes
 *
 */

import React from "react";
import { connect } from "react-redux";
import { Route } from "react-router-dom";
import { LinkContainer } from "react-router-bootstrap";
import { Row, Col, ListGroup } from "react-bootstrap";

import { findViruses } from "../actions";
import { Icon, ListGroupItem } from "virtool/js/components/Base";
import VirusToolbar from "./Toolbar";
import CreateVirus from "./Create";

class VirusesList extends React.Component {

    constructor (props) {
        super(props)
    }

    static propTypes = {
        documents: React.PropTypes.arrayOf(React.PropTypes.object),
        onFind: React.PropTypes.func
    };

    componentDidMount () {
        if (this.props.documents === null) {
            this.props.onFind(null);
        }
    }

    render () {

        let virusComponents;

        if (this.props.documents && this.props.documents.length > 0) {
            virusComponents = this.props.documents.map(document =>
                <LinkContainer to={`/viruses/${document.virus_id}`} key={document.virus_id} className="spaced">
                    <ListGroupItem bsStyle={document.modified ? "warning": null}>
                        <Row>
                            <Col sm={12} md={6}>
                                <strong>{document.name}</strong>
                            </Col>
                            <Col sm={12} md={6}>
                                {document.abbreviation}
                                <span className="pull-right">
                                    {document.modified ? <Icon bsStyle="warning" name="flag" />: null}
                                </span>
                            </Col>
                        </Row>
                    </ListGroupItem>
                </LinkContainer>
            );
        } else {
            virusComponents = (
                <ListGroupItem key="noViruses" className="text-center">
                    <Icon name="info"/> No viruses found.
                </ListGroupItem>
            );
        }

        return (
            <div>
                <VirusToolbar {...this.props} />

                <ListGroup>
                    {virusComponents}
                </ListGroup>

                <Route path="/viruses/create">
                    <CreateVirus {...this.props} />
                </Route>
            </div>
        );

    }
}

const mapStateToProps = (state) => {
    return {
        documents: state.viruses.documents,
        finding: state.viruses.finding,
        find: state.viruses.find,
        sort: state.viruses.sort,
        descending: state.viruses.descending,
        modified: state.viruses.modified,
        account: state.account
    };
};

const mapDispatchToProps = (dispatch, ownProps) => {
    return {
        onFind: (term) => {
            dispatch(findViruses({find: term || null}));
        },

        onToggleModifiedOnly: () => {
            dispatch(findViruses({modified: !ownProps.modified}));
        }
    };
};

const Container = connect(
    mapStateToProps,
    mapDispatchToProps
)(VirusesList);

export default Container;
