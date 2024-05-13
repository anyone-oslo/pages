import React from "react";

import { csrfToken } from "../../lib/request";

interface FormProps {
  state: PageForm.State;
  children: React.ReactNode;
}

function pageUrl(state: PageForm.State): string {
  if (state.page.id) {
    return `/admin/${state.locale}/pages/${state.page.id}`;
  } else {
    return `/admin/${state.locale}/pages`;
  }
}

export default function Form(props: FormProps) {
  const { state, children } = props;
  const { page } = state;

  return (
    <form
      className="edit-page main-wrapper"
      method="post"
      acceptCharset="UTF-8"
      action={pageUrl(state)}>
      {page.id && (
        <input type="hidden" name="_method" value="put" autoComplete="off" />
      )}
      <input
        type="hidden"
        autoComplete="off"
        name="authenticity_token"
        value={csrfToken()}
      />
      {children}
    </form>
  );
}
