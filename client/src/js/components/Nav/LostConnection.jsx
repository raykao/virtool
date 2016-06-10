/**
 * @license
 * The MIT License (MIT)
 * Copyright 2015 Government of Canada
 *
 * @author
 * Ian Boyes
 *
 * @exports LostConnection
 */

'use strict';

var React = require('react');
var Modal = require('react-bootstrap/lib/Modal');
var Icon = require('virtool/js/components/Base/Icon.jsx');

var PushButton = require('virtool/js/components/Base/PushButton.jsx');

var LostConnection = React.createClass({

    propTypes: {
        show: React.PropTypes.bool.isRequired
    },

    render: function () {
        return (
            <div>
                <Modal {...this.props} animation={false} bsSize='small'>
                    <Modal.Body {...this.props} className='text-center'>
                        <h5><Icon name='warning' bsStyle='danger' /> Lost Connection</h5>
                    </Modal.Body>
                </Modal>
            </div>
        );
    }

});

module.exports = LostConnection;