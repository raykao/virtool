import styled from "styled-components";
import { getColor } from "../app/theme";

export const getLabelColor = props => getColor(props) || props.theme.color.greyDark;

export const Label = styled.span`
    background-color: ${getLabelColor};
    border-radius: 2px;
    color: #ffffff;
    display: inline;
    font-size: 12px;
    font-weight: bold;
    padding: 3px 5px;
    text-align: center;
    white-space: nowrap;
    vertical-align: baseline;

    ${props => (props.spaced ? "margin-right: 5px;" : "")}

    &:last-of-type {
        margin: 0;
    }
`;
