import React from "react";
import { connect } from "react-redux";
import { Row, Col, Panel } from "react-bootstrap";

import { updateSetting } from "../../actions";
import { Icon, Flex, FlexItem, InputError, Checkbox } from "../../../base";

const SSLFooter = () => (
    <small className="text-warning">
        <Icon name="warning" /> Changes to these settings will only take effect when the server is reloaded.
    </small>
);

const SSLOptions = (props) => (
    <div>
        <Row>
            <Col xs={12} md={6}>
                <Flex alignItems="center" style={{marginBottom: "10px"}}>
                    <FlexItem grow={1}>
                        <strong>SSL</strong>
                    </FlexItem>
                    <FlexItem>
                        <Checkbox
                            label="Enable"
                            checked={props.enabled}
                            onClick={() => {props.onToggle(!props.enabled)}}
                        />
                    </FlexItem>
                </Flex>
            </Col>
            <Col smHidden md={6} />
        </Row>
        <Row>
            <Col xs={12} md={6} mdPush={6}>
                <Panel footer={<SSLFooter />}>
                    Configure the server to use SSL.
                </Panel>
            </Col>
            <Col xs={12} md={6} mdPull={6}>
                <Panel>
                    <InputError
                        label="Certificate Path"
                        onSave={props.onUpdateCertPath}
                        initialValue={props.certPath}
                        disabled={!props.enabled}
                        noMargin
                        withButton
                    />
                    <InputError
                        label="Key Path"
                        onSave={props.onUpdateKeyPath}
                        initialValue={props.keyPath}
                        disabled={!props.enabled}
                        noMargin
                        withButton
                    />
                </Panel>
            </Col>
        </Row>
    </div>
);

const mapStateToProps = (state) => ({
    enabled: state.settings.data.use_ssl,
    certPath: state.settings.data.cert_path,
    keyPath: state.settings.data.key_path
});

const mapDispatchToProps = (dispatch) => ({

    onToggle: (value) => {
        dispatch(updateSetting("use_ssl", value));
    },

    onUpdateCertPath: (e) => {
        dispatch(updateSetting("cert_path", e.value));
    },

    onUpdateKeyPath: (e) => {
        dispatch(updateSetting("key_path", e.value));
    }

});

const Container = connect(mapStateToProps, mapDispatchToProps)(SSLOptions);

export default Container;
