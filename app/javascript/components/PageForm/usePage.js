import { useState } from "react";

export function blockValue(page, block, locale) {
  if (block.localized) {
    return page[block.name][locale];
  } else {
    return page[block.name];
  }
}

export function updateBlock(page, setPage, block, locale) {
  return (newValue) => {
    let nextValue = newValue;
    if (block.localized) {
      nextValue = { ...page[block.name], [locale]: newValue };
    }
    setPage({ ...page, [block.name]: nextValue });
  };
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

function parsedDates(page) {
  return { published_at: parseDate(page.published_at),
           starts_at: parseDate(page.starts_at),
           ends_at: parseDate(page.ends_at) };
}

export default function usePage(initialPage, templates) {
  const [page, setPage] = useState({
    ...initialPage,
    ...parsedDates(initialPage)
  });

  const templateConfig = templates
        .filter(t => t.template_name === page.template)[0];

  return [page, setPage, templateConfig];
}
