import { useReducer} from "react";

export function blockValue(state, block) {
  if (block.localized) {
    return state.page[block.name][state.locale] || "";
  } else {
    return state.page[block.name] || "";
  }
}

export function errorsOn(page, attribute) {
  return page.errors
    .filter(e => e.attribute === attribute)
    .map(e => e.message);
}

function parseDate(str) {
  if (!str) {
    return null;
  } else if (typeof(str) === "string") {
    return new Date(str);
  } else {
    return str;
  }
}

function derivedState(state) {
  const { locale, locales, page, templates } = state;
  return {
    ...state,
    inputDir: (locales && locales[locale] && locales[locale].dir) || "ltr",
    templateConfig: templates.filter(t => t.template_name === page.template)[0]
  };
}

function parsedDates(page) {
  return { published_at: parseDate(page.published_at),
           starts_at: parseDate(page.starts_at),
           ends_at: parseDate(page.ends_at) };
}

function localizedAttributes(templates) {
  return ["path_segment",
          ...new Set(templates
                     .flatMap(t => [...t.blocks, ...t.metadata_blocks])
                     .filter(b => b.localized)
                     .map(b => b.name))];
}

function prepare(state) {
  const page = { ...state.page, ...parsedDates(state.page) };
  return { ...state, page: page };
}

function reducer(state, action) {
  const { type, payload } = action;
  switch (type) {
  case "setLocale":
    return { ...state, locale: payload };
  case "update":
    return updatePage(state, payload);
  default:
    return state;
  }
}

function updatePage(state, attributes) {
  const { locale, templates, page } = state;
  let nextPage = {};

  Object.keys(attributes).forEach((attr) => {
    if (localizedAttributes(templates).indexOf(attr) !== -1) {
      nextPage[attr] = { ...page[attr], [locale]: attributes[attr] };
    } else {
      nextPage[attr] = attributes[attr];
    }
  });

  return { ...state, page: { ...page, ...nextPage } };
}

export default function usePage(initialState) {
  const [state, dispatch] = useReducer(reducer, prepare(initialState));
  return [derivedState(state), dispatch];
}
