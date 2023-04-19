import React, { ChangeEvent } from "react";

import { errorsOn, PageFormAction, PageFormState } from "./usePage";
import LabelledField from "../LabelledField";

interface PathSegmentProps {
  state: PageFormState;
  dispatch: (action: PageFormAction) => void;
}

function missingPathSegment(ancestors: PageAncestor[], locale: string) {
  for (let i = 0; i < ancestors.length; i++) {
    if (!ancestors[i].path_segment[locale]) {
      return ancestors[i];
    }
  }
  return null;
}

export default function PathSegment(props: PathSegmentProps) {
  const { state, dispatch } = props;
  const { page, locale } = state;

  const handleChange = (evt: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: "update", payload: { path_segment: evt.target.value } });
  };

  const editAncestor = missingPathSegment(page.ancestors, locale);

  if (editAncestor) {
    const editUrl = `/admin/${locale}/pages/${editAncestor.id}/edit#metadata`;
    return (
      <LabelledField label="Path segment">
        <p className="description">
          Unable to add a path segment to this page, please add one to{" "}
          <a href={editUrl}>this page&apos;s ancestor</a> first.
        </p>
      </LabelledField>
    );
  }

  return (
    <LabelledField
      htmlFor="page_path_segment"
      label="Path segment"
      errors={errorsOn(page, "path_segment")}>
      <input
        type="text"
        id="page_path_segment"
        name="page[path_segment]"
        lang={state.locale}
        dir="ltr"
        onChange={handleChange}
        value={page.path_segment[locale]}
      />
    </LabelledField>
  );
}
