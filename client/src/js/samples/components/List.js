import React from "react";
import { Route } from "react-router-dom";
import { push } from "react-router-redux";
import { connect } from "react-redux";
import { ListGroup, Pagination } from "react-bootstrap";

import { findSamples } from "../actions";
import { Icon, ListGroupItem, ViewHeader } from "../../base";
import SampleEntry from "./Entry";
import SampleToolbar from "./Toolbar";
import CreateSample from "./Create/Create";
import QuickAnalyze from "./QuickAnalyze";

class SamplesList extends React.Component {

    componentDidMount () {
        this.props.onFind();
    }

    handleChange = (value) => {
        const url = new window.URL(window.location);

        if (value) {
            url.searchParams.set("find", value);
        } else {
            url.searchParams.delete("find");
        }

        this.props.onFind(url);
    };

    handlePage = (page) => {
        const url = new window.URL(window.location);
        url.searchParams.set("page", page);
        this.props.onFind(url);
    };

    render () {

        if (this.props.documents === null) {
            return <div />;
        }

        const term = this.props.match.params.term;

        let sampleComponents = this.props.documents.map(document =>
            <SampleEntry
                key={document.id}
                id={document.id}
                userId={document.user.id}
                {...document}
            />
        );

        if (!sampleComponents.length) {
            sampleComponents = (
                <ListGroupItem key="noSample" className="text-center">
                    <Icon name="info"/> No samples found.
                </ListGroupItem>
            );
        }

        return (
            <div>
                <ViewHeader
                    title="Samples"
                    page={this.props.page}
                    count={this.props.documents.length}
                    foundCount={this.props.found_count}
                    totalCount={this.props.total_count}
                />

                <SampleToolbar
                    term={term}
                    onTermChange={this.handleChange}
                    history={this.props.history}
                    location={this.props.location}
                    canCreate={this.props.canCreate}
                />

                <ListGroup>
                    {sampleComponents}
                </ListGroup>

                <div className="text-center">
                    <Pagination
                        onSelect={this.handlePage}
                        items={this.props.page_count}
                        maxButtons={10}
                        activePage={this.props.page}
                        first
                        last
                        next
                        prev
                    />
                </div>

                <Route path="/samples" render={({ history }) =>
                    <CreateSample
                        show={!!(history.location.state && history.location.state.create)}
                        onHide={this.props.onHide}
                    />
                } />

                <Route path="/samples" render={({ history }) =>
                    <QuickAnalyze
                        show={!!(history.location.state && history.location.state.quickAnalyze)}
                        {...(history.location.state ? history.location.state.quickAnalyze: {})}
                        onHide={this.props.onHide}
                    />
                } />
            </div>
        );
    }
}

const mapStateToProps = (state) => {
    return {...state.samples, canCreate: state.account.permissions.create_sample};
};

const mapDispatchToProps = (dispatch) => {
    return {
        onFind: (url = new window.URL(window.location)) => {
            dispatch(push(url.pathname + url.search));
            dispatch(findSamples(url.searchParams.get("find"), url.searchParams.get("page") || 1));
        },

        onHide: () => {
            dispatch(push({state: {}}));
        }
    };
};

const Container = connect(mapStateToProps, mapDispatchToProps)(SamplesList);

export default Container;
