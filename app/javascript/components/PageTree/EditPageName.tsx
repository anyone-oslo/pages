import { useState } from "react";

import * as Tree from "./tree";
import { updatePage } from "./usePageTree";
import usePageTreeContext from "./usePageTreeContext";
import Button from "./Button";

type Props = {
  id: Tree.Id;
};

export default function EditPageName({ id }: Props) {
  const { state, dispatch } = usePageTreeContext();
  const { dir, locale } = state;
  const node = state.nodes[id];
  const page = node.record;
  const [name, setName] = useState(page.blocks.name[locale]);

  const handleCancel = () => {
    if ("id" in page && page.id) {
      dispatch({ type: "update", id: id, payload: { editing: false } });
    } else {
      dispatch({ type: "remove", id: id });
    }
  };

  const handleChange = (evt: React.ChangeEvent<HTMLInputElement>) => {
    setName(evt.target.value);
  };

  const handleSubmit = (evt: React.FormEvent) => {
    evt.preventDefault();
    updatePage(state, id, dispatch, {
      blocks: {
        ...page.blocks,
        name: { ...page.blocks.name, [locale]: name }
      },
      editing: false
    });
  };

  return (
    <div className="page edit">
      <i className="fa-regular fa-file icon"></i>
      <form className="edit-name" onSubmit={handleSubmit}>
        <input
          className="tight"
          type="text"
          value={name}
          dir={dir}
          lang={locale}
          autoFocus
          onChange={handleChange}
        />
        <button className="save primary" type="submit">
          <i className="fa-solid fa-cloud icon"></i>
          Save
        </button>
        <Button
          label="Cancel"
          className="cancel"
          icon="ban"
          onClick={handleCancel}
        />
      </form>
    </div>
  );
}
