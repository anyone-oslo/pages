import { useMemo, useReducer } from "react";

import * as Pages from "../../types/Pages";
import { postJson, putJson } from "../../lib/request";
import * as Tree from "./tree";

type CollapsedState = Record<number, boolean>;
type RootRecord = {
  blocks: Pages.Blocks;
  permissions: string[];
  root: true;
  editing: false;
};
type PageRecord = Pages.TreeResource;
type TreeRecord = RootRecord | PageRecord;

export type State = Tree.State<TreeRecord> & {
  locale: string;
  dir: string;
};

export type Action =
  | {
      type: "move";
      id: Tree.Id;
      payload: { parent: Tree.Id; position: number };
    }
  | { type: "append" | "addChild"; id: Tree.Id; payload: TreeRecord }
  | { type: "remove" | "sortNewsPage"; id: Tree.Id }
  | { type: "setCollapsed"; id: Tree.Id; payload: boolean }
  | { type: "update"; id: Tree.Id; payload: Partial<TreeRecord> };

const permittedAttributes = [
  "status",
  "news_page",
  "published_at",
  "pinned",
  "parent_page_id"
];

export function movePage(
  prevState: State,
  id: Tree.Id,
  dispatch: React.Dispatch<Action>
) {
  const state = sortNewsPage(prevState, prevState.nodes[id].parent);
  const node = state.nodes[id];
  const parentNode = state.nodes[node.parent];
  const position = parentNode.childNodes.indexOf(id);

  if ("id" in node.record && node.record.id) {
    const data = {
      parent_id: !("root" in parentNode.record) && parentNode.record.id,
      position: position + 1
    };

    dispatch({
      type: "move",
      id: id,
      payload: { parent: parentNode.id, position: position }
    });

    putJson(
      `/admin/${state.locale}/pages/${node.record.id}/move.json`,
      data
    ).then((response) => {
      dispatch({ type: "update", id: id, payload: response });
    });
  }
}

export function updatePage(
  state: State,
  id: Tree.Id,
  dispatch: React.Dispatch<Action>,
  attributes: Partial<PageRecord>
) {
  const node = state.nodes[id];
  const page = node.record;
  const updateState = (updated: Partial<PageRecord>) => {
    dispatch({
      type: "update",
      id: id,
      payload: { ...attributes, ...updated }
    });
  };

  let data = {};
  if (attributes.blocks) {
    data = { ...attributes.blocks };
  }
  permittedAttributes.forEach((a) => {
    if (Object.prototype.hasOwnProperty.call(attributes, a)) {
      data[a] = attributes[a];
    }
  });

  if ("id" in page) {
    putJson(`/admin/${state.locale}/pages/${page.id}.json`, {
      page: data
    }).then(updateState);
  } else {
    const parent = state.nodes[node.parent];
    if (parent && "id" in parent.record) {
      data = { parent_page_id: parent.record.id, ...data };
    }
    postJson(`/admin/${state.locale}/pages.json`, { page: data }).then(
      updateState
    );
  }
}

export function visibleChildNodes(state: State, id: Tree.Id) {
  return state.nodes[id].childNodes
    .map((i) => state.nodes[i])
    .filter((n) => "status" in n.record && n.record.status !== 4)
    .map((n) => n.id);
}

export function addChild(
  state: State,
  id: Tree.Id,
  dispatch: React.Dispatch<Action>
) {
  const parentNode = state.nodes[id];

  const record: PageRecord = {
    blocks: { name: { [state.locale]: "" } },
    status: 0,
    editing: true,
    news_page: false,
    published_at: new Date(),
    pinned: false,
    parent_page_id: "id" in parentNode.record && parentNode.record.id,
    permissions: parentNode.record.permissions
  };

  dispatch({ type: "addChild", id: id, payload: record });
}

function setCollapsed(state: State, id: Tree.Id, value: boolean): State {
  const node = state.nodes[id];
  if ("id" in node.record) {
    storeCollapsed(node.record.id, value);
  }
  return { ...state, ...Tree.updateNode(state, id, { collapsed: value }) };
}

function sortNewsPage(state: State, id: Tree.Id) {
  const record = state.nodes[id].record;
  if ("news_page" in record && record.news_page) {
    return { ...state, ...Tree.sortChildNodes(state, id, sortChildren) };
  } else {
    return state;
  }
}

function reducer(state: State, action: Action): State {
  const { id, type } = action;

  const chain = (operations: Array<Partial<Action>>) => {
    return operations.reduce((s, o) => {
      return reducer(s, { id: id, ...o } as Action);
    }, state);
  };

  switch (type) {
    case "addChild": {
      return chain([
        { type: "setCollapsed", payload: false },
        { type: "append", payload: action.payload },
        { type: "sortNewsPage" }
      ]);
    }
    case "append":
      return { ...state, ...Tree.insert(state, id, action.payload, -1) };
    case "move":
      return {
        ...state,
        ...Tree.move(state, id, action.payload.parent, action.payload.position)
      };
    case "remove":
      return { ...state, ...Tree.remove(state, id) };
    case "setCollapsed":
      return { ...state, ...setCollapsed(state, id, action.payload) };
    case "sortNewsPage":
      return { ...state, ...sortNewsPage(state, id) };
    case "update":
      return { ...state, ...Tree.update(state, id, action.payload) };
    default:
      return state;
  }
}

function collapsedState(): CollapsedState {
  return JSON.parse(window?.localStorage?.getItem("collapsedPages") || "{}");
}

function storeCollapsed(id: number, value: boolean) {
  const state = { ...collapsedState(), [id]: value };
  window.localStorage.setItem("collapsedPages", JSON.stringify(state));
}

function sortChildren(a: Tree.Node<PageRecord>, b: Tree.Node<PageRecord>) {
  if (a.record.pinned == b.record.pinned) {
    return (
      new Date(b.record.published_at).getTime() -
      new Date(a.record.published_at).getTime()
    );
  } else {
    return a.record.pinned ? -1 : 1;
  }
}

function indexingReducer(state: State, action: Action): State {
  return { ...state, ...Tree.indexPositions(reducer(state, action)) };
}

export default function usePageTree(
  pages: PageRecord[],
  locale: string,
  dir: string,
  permissions: string[]
): [State, React.Dispatch<Action>] {
  const root: RootRecord = {
    blocks: { name: { [locale]: "All Pages" } },
    permissions: permissions,
    root: true,
    editing: false
  };

  const parentMap = useMemo(() => {
    return pages.reduce((m, p) => {
      const id = p.parent_page_id || 0;
      m[id] = [...(m[id] || []), p];
      return m;
    }, {});
  }, [pages]);

  const isCollapsed = (page: PageRecord) => {
    const state = collapsedState();
    if (page.id && page.id in state) {
      return state[page.id];
    } else if (page.news_page || page.parent_page_id) {
      return true;
    }
    return false;
  };

  const initNode = (page: TreeRecord) => {
    if ("root" in page) {
      return { children: parentMap[0], collapsed: false };
    } else if (page.id) {
      return { children: parentMap[page.id], collapsed: isCollapsed(page) };
    } else {
      return { children: [], collapsed: false };
    }
  };

  const [state, dispatch] = useReducer(indexingReducer, {}, () => {
    return {
      ...Tree.indexPositions(Tree.build(root, initNode)),
      dir: dir,
      locale: locale
    };
  });
  return [state, dispatch];
}
