import { useState } from "react";

import * as PageEditor from "../../types/PageEditor";
import { unconfiguredBlocks } from "./utils";

function tabsList(state: PageEditor.State): PageEditor.Tab[] {
  const { templates, templateConfig } = state;
  const tabs: PageEditor.Tab[] = [
    { id: "content", name: "Content", enabled: true }
  ];
  if (templates.filter((t) => t.images).length > 0) {
    tabs.push({ id: "images", name: "Images", enabled: templateConfig.images });
  }
  if (templates.filter((t) => t.files).length > 0) {
    tabs.push({ id: "files", name: "Files", enabled: templateConfig.files });
  }
  tabs.push({ id: "metadata", name: "Metadata", enabled: true });
  if (unconfiguredBlocks(state).length > 0) {
    tabs.push({
      id: "unconfigured-content",
      name: "Unconfigured content",
      enabled: true
    });
  }
  return tabs;
}

function initialTab(tabs: PageEditor.Tab[]): string {
  const tabExpression = /#(.*)$/;
  if (document.location.toString().match(tabExpression)) {
    const id = document.location.toString().match(tabExpression)[1];
    const matchingTab = tabs.filter((t) => t.id == id)[0];
    if (matchingTab) {
      return matchingTab.id;
    }
  }
  return tabs[0].id;
}

export default function useTabs(
  state: PageEditor.State
): [PageEditor.Tab[], string, (tab: string) => void] {
  const tabs = tabsList(state);
  const [tab, setTab] = useState<string>(initialTab(tabs));
  return [tabs, tab, setTab];
}
