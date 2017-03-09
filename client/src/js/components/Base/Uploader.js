import React from "react";
import Numeral from "numeral";
import Dropzone from "react-dropzone";
import FlipMove from "react-flip-move";
import { sortBy } from "lodash";
import { Icon, RelativeTime, ProgressBar } from "virtool/js/components/Base";
import { Row, Col } from "react-bootstrap";
import { Flex, Button, ListGroupItem, getFlipMoveProps } from "virtool/js/components/Base";


export class FileItem extends React.PureComponent {

    static propTypes = {
        _id: React.PropTypes.string.isRequired,
        name: React.PropTypes.string.isRequired,
        timestamp: React.PropTypes.string.isRequired,
        created: React.PropTypes.bool,
        ready: React.PropTypes.bool,
        size_now: React.PropTypes.number.isRequired,
        size_end: React.PropTypes.number.isRequired,
        remove: React.PropTypes.func.isRequired
    };

    static defaultProps = {
        created: false,
        ready: false
    };

    render = () => {

        let removeIcon;

        if (this.props.ready) {
            removeIcon = (
                <Icon
                    className="pull-right"
                    name="remove"
                    bsStyle="danger"
                    onClick={() => this.props.remove(this.props._id)}
                />
            );
        }

        return (
            <ListGroupItem className="spaced">
                <ProgressBar
                    bsStyle={this.props.ready ? null : "success"}
                    now={this.props.created ? this.props.size_now / this.props.size_end * 100 : 0}
                    affixed
                />
                <Row>
                    <Col md={5}>
                        <Icon name="file"/> {this.props.name}
                    </Col>
                    <Col md={3}>
                        Added <RelativeTime time={this.props.timestamp}/>
                    </Col>
                    <Col md={2}>
                        <span className="pull-right">
                            {Numeral(this.props.size_now).format("0.0 b")}
                        </span>
                    </Col>
                    <Col md={2}>
                        {removeIcon}
                    </Col>
                </Row>
            </ListGroupItem>
        );
    };
}

export const Uploader = (props) => {

    let dropzone;

    let fileComponents;

    const files = props.fileDocuments.branch().data();

    if (files.length > 0) {
        fileComponents = sortBy(files, "timestamp").reverse().map(file =>
            <div key={file._id}>
                <FileItem {...file} remove={props.onRemove} />
            </div>
        );
    } else {
        fileComponents = (
            <ListGroupItem className="text-center" key="noFiles">
                <Icon name="info" /> No files found
            </ListGroupItem>
        );
    }

    return (
        <div>
            <Flex>
                <Dropzone
                    ref={(node) => dropzone = node}
                    onDrop={props.onDrop}
                    className="dropzone"
                    activeClassName="dropzone-active"
                    disableClick
                >
                    Drag file here to upload
                </Dropzone>

                <Button icon="folder-open" style={{marginLeft: "3px"}} onClick={() => dropzone.open()}/>
            </Flex>

            <FlipMove {...getFlipMoveProps()} style={{marginTop: "15px"}}>
                {fileComponents}
            </FlipMove>
        </div>
    );
};

Uploader.propTypes = {
    fileDocuments: React.PropTypes.object,
    onDrop: React.PropTypes.func.isRequired,
    onRemove: React.PropTypes.func.isRequired
};
