import React from "react";
import PropTypes from "prop-types";

import { csrfToken } from "../../lib/request";

function pageUrl(state) {
  if (state.page.id) {
    return `/admin/${state.locale}/pages/${state.page.id}`;
  } else {
    return `/admin/${state.locale}/pages`;
  }
}

export default function Form(props) {
  const { state, children } = props;
  const { page } = state;

  return (
    <form className="edit-page main-wrapper" method="post" ref={props.ref}
          acceptCharset="UTF-8" action={pageUrl(state)}>
      {page.id && <input type="hidden" name="_method" value="put"
                         autoComplete="off" />}
      <input type="hidden" autoComplete="off" name="authenticity_token"
             value={csrfToken()} />
      {children}
    </form>
  );
}

Form.propTypes = {
  ref: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.shape({ current: PropTypes.any })
  ]),
  state: PropTypes.object,
  children: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object,
    PropTypes.array
  ]),
};
