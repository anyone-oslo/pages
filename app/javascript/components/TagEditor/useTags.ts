import { useReducer } from "react";

import * as Tags from "../../types/Tags";

function onlyUnique(value: string, index: number, self: string[]) {
  return self.indexOf(value) === index;
}

export function allTags(state: Tags.State) {
  return [...state.tags, ...state.enabled].filter(onlyUnique);
}

function normalize(tag: string, state: Tags.State) {
  return (
    allTags(state).filter((t) => t.toLowerCase() == tag.toLowerCase())[0] || tag
  );
}

export function isEnabled(tag: string, state: Tags.State) {
  return (
    state.enabled.map((t) => t.toLowerCase()).indexOf(tag.toLowerCase()) !== -1
  );
}

function toggle(tag: string, state: Tags.State) {
  if (isEnabled(tag, state)) {
    return { ...state, enabled: state.enabled.filter((t) => t !== tag) };
  } else {
    return { ...state, enabled: [...state.enabled, tag] };
  }
}

function reducer(state: Tags.State, action: Tags.Action) {
  const { type, payload } = action;
  switch (type) {
    case "addTag": {
      const normalized = normalize(payload, state);
      return {
        tags: [...state.tags, normalized].filter(onlyUnique),
        enabled: [...state.enabled, normalized].filter(onlyUnique)
      };
    }
    case "toggleTag":
      return toggle(normalize(payload, state), state);
    case "update":
      return payload;
    default:
      return state;
  }
}

export default function useTags(
  initTags: string[],
  initEnabled: string[]
): [Tags.State, React.Dispatch<Tags.Action>] {
  const [state, dispatch] = useReducer(reducer, {
    tags: initTags,
    enabled: initEnabled
  });
  return [state, dispatch];
}
