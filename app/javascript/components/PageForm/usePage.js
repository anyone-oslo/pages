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
  return page.errors.filter(e => e.attribute === attribute).map(e => e.message);
}

export default function usePage(initialPage, templates) {
  const [page, setPage] = useState(initialPage);

  const templateConfig = templates
        .filter(t => t.template_name === page.template)[0];

  return [page, setPage, templateConfig];
}
