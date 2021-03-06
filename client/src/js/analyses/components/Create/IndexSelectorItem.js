import React, { useCallback } from "react";
import styled from "styled-components";
import { Checkbox, BoxGroupSection, Label } from "../../../base";

const StyledIndexSelectorItem = styled(BoxGroupSection)`
    align-items: center;
    display: flex;

    strong {
        margin-left: 8px;
    }

    > span:last-child {
        margin-left: auto;
    }
`;

export const IndexSelectorItem = ({ id, reference, isSelected, version, onSelect }) => {
    const handleClick = useCallback(() => onSelect({ id, refId: reference.id }), []);

    return (
        <StyledIndexSelectorItem onClick={handleClick}>
            <Checkbox checked={isSelected} />
            <strong>{reference.name}</strong>
            <span>
                Index Version <Label>{version}</Label>
            </span>
        </StyledIndexSelectorItem>
    );
};
