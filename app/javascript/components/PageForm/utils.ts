import * as PageEditor from "../../types/PageEditor";
import * as Pages from "../../types/Pages";
import * as Template from "../../types/Template";
import { LocalizedValue, MaybeLocalizedValue } from "../../types";

export function blockValue(
  state: PageEditor.State,
  block: Template.Block
): string {
  if (block.localized) {
    const value: LocalizedValue =
      (state.page.blocks[block.name] as LocalizedValue) || {};

    return value[state.locale] || "";
  } else {
    return (state.page.blocks[block.name] as string) || "";
  }
}

export function errorsOn(page: Pages.Resource, attribute: string): string[] {
  return page.errors
    .filter((e) => e.attribute === attribute)
    .map((e) => e.message);
}

export function unconfiguredBlocks(state: PageEditor.State): Template.Block[] {
  const allBlocks: Record<string, Template.Block> = state.templates
    .flatMap((t) => t.blocks)
    .reduce((bs, b) => ({ [b.name]: b, ...bs }), {});

  const anyValue = (v: MaybeLocalizedValue) => {
    if (typeof v === "string") {
      return v ? true : false;
    } else {
      return Object.values(v).filter((v) => v).length > 0;
    }
  };

  const hasValue = Object.keys(allBlocks).filter((k) => {
    const value = state.page.blocks[k] || "";
    return anyValue(value);
  });

  const enabled = state.templateConfig.blocks.map((b) => b.name);

  return hasValue
    .filter((b) => enabled.indexOf(b) === -1)
    .map((n) => allBlocks[n]);
}
