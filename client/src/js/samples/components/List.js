import React from "react";
import { Route } from "react-router-dom";
import { push } from "react-router-redux";
import { connect } from "react-redux";
import { ListGroup } from "react-bootstrap";

import SampleEntry from "./Entry";
import SampleToolbar from "./Toolbar";
import CreateSample from "./Create/Create";
import QuickAnalyze from "./QuickAnalyze";
import { LoadingPlaceholder, NoneFound, Pagination, ViewHeader } from "../../base";
import { createFindURL } from "../../utils";

const SamplesList = (props) => {

    if (props.documents === null) {
        return <LoadingPlaceholder />;
    }

    let sampleComponents = props.documents.map(document =>
        <SampleEntry
            key={document.id}
            id={document.id}
            userId={document.user.id}
            {...document}
        />
    );

    if (!props.documents.length) {
        sampleComponents = <NoneFound key="noSample" noun="samples" noListGroup />;
    }

    return (
        <div>
            <ViewHeader
                title="Samples"
                page={props.page}
                count={props.documents.length}
                foundCount={props.found_count}
                totalCount={props.total_count}
            />

            <SampleToolbar />

            <ListGroup>
                {sampleComponents}
            </ListGroup>

            <Pagination
                documentCount={props.documents.length}
                onPage={props.onFind}
                page={props.page}
                pageCount={props.page_count}
            />

            <Route path="/samples" render={({ history }) =>
                <CreateSample
                    show={!!(history.location.state && history.location.state.create)}
                    onHide={props.onHide}
                />
            } />

            <Route path="/samples" render={({ history }) =>
                <QuickAnalyze
                    show={!!(history.location.state && history.location.state.quickAnalyze)}
                    {...(history.location.state ? history.location.state.quickAnalyze : {})}
                    onHide={props.onHide}
                />
            } />
        </div>
    );
};

const mapStateToProps = (state) => ({...state.samples});

const mapDispatchToProps = (dispatch) => ({

    onFind: (page) => {
        const url = createFindURL({page});
        dispatch(push(url.pathname + url.search));
    },

    onHide: () => {
        dispatch(push({state: {}}));
    }

});

const Container = connect(mapStateToProps, mapDispatchToProps)(SamplesList);

export default Container;
