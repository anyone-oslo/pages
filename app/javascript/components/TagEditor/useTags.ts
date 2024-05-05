import { useReducer } from "react";

function onlyUnique(value: string, index: number, self: string[]) {
  return self.indexOf(value) === index;
}

export function allTags(state: TagEditor.State) {
  return [...state.tags, ...state.enabled].filter(onlyUnique);
}

function normalize(tag: string, state: TagEditor.State) {
  return (
    allTags(state).filter((t) => t.toLowerCase() == tag.toLowerCase())[0] || tag
  );
}

export function isEnabled(tag: string, state: TagEditor.State) {
  return (
    state.enabled.map((t) => t.toLowerCase()).indexOf(tag.toLowerCase()) !== -1
  );
}

function toggle(tag: string, state: TagEditor.State) {
  if (isEnabled(tag, state)) {
    return { ...state, enabled: state.enabled.filter((t) => t !== tag) };
  } else {
    return { ...state, enabled: [...state.enabled, tag] };
  }
}

function reducer(state: TagEditor.State, action: TagEditor.Action) {
  const { type, payload } = action;
  const normalized = normalize(payload, state);
  switch (type) {
    case "addTag":
      return {
        tags: [...state.tags, normalized].filter(onlyUnique),
        enabled: [...state.enabled, normalized].filter(onlyUnique)
      };
    case "toggleTag":
      return toggle(normalized, state);
    default:
      return state;
  }
}

export default function useTags(
  initTags: string[],
  initEnabled: string[]
): [TagEditor.State, (action: TagEditor.Action) => void] {
  const [state, dispatch] = useReducer(reducer, {
    tags: initTags,
    enabled: initEnabled
  });
  return [state, dispatch];
}
