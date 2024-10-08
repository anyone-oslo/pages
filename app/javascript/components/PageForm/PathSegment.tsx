import { ChangeEvent } from "react";

import * as PageEditor from "../../types/PageEditor";
import * as Pages from "../../types/Pages";
import { LocalizedValue } from "../../types";

import { errorsOn } from "./usePage";
import LabelledField from "../LabelledField";

interface Props {
  state: PageEditor.State;
  dispatch: (action: PageEditor.Action) => void;
}

function missingPathSegment(ancestors: Pages.Ancestor[], locale: string) {
  for (let i = 0; i < ancestors.length; i++) {
    if (!ancestors[i].path_segment[locale]) {
      return ancestors[i];
    }
  }
  return null;
}

export default function PathSegment(props: Props) {
  const { state, dispatch } = props;
  const { page, locale } = state;

  const value = (page.path_segment as LocalizedValue)[locale];

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
      description="Only alpanumeric characters and dashes are allowed."
      errors={errorsOn(page, "path_segment")}>
      <input
        type="text"
        id="page_path_segment"
        name="page[path_segment]"
        lang={state.locale}
        dir="ltr"
        onChange={handleChange}
        value={value}
      />
    </LabelledField>
  );
}
