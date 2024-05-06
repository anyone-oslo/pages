import React, { useEffect, useState, useRef } from "react";

import { putJson, postJson } from "../lib/request";
import { openPreview } from "./PageForm/preview";
import useToastStore from "../stores/useToastStore";
import useAttachments from "./Attachments/useAttachments";
import useImageGrid from "./ImageGrid/useImageGrid";
import useTags from "./TagEditor/useTags";
import usePage, { unconfiguredBlocks } from "./PageForm/usePage";
import pageParams from "./PageForm/pageParams";
import Content from "./PageForm/Content";
import UnconfiguredContent from "./PageForm/UnconfiguredContent";
import Metadata from "./PageForm/Metadata";
import Form from "./PageForm/Form";
import PageDescription from "./PageForm/PageDescription";
import Options from "./PageForm/Options";
import Tabs from "./PageForm/Tabs";
import TabPanel from "./PageForm/TabPanel";
import Files from "./PageForm/Files";
import Images from "./PageForm/Images";

interface Props {
  locale: string;
  locales: { [index: string]: Locale };
  page: Page.SerializedResource;
  templates: Template.Config[];
  authors: Page.Author[];
  statuses: Page.StatusLabels;
}

function tabsList(state: PageForm.State): PageForm.Tab[] {
  const { templates, templateConfig } = state;
  const tabs: PageForm.Tab[] = [
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

function initialTab(tabs: PageForm.Tab[]): string {
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

export default function PageForm(props: Props) {
  const formRef = useRef(null);
  const [state, dispatch] = usePage({
    locales: props.locales,
    locale: props.locale,
    page: props.page,
    templates: props.templates
  });
  const { page, locale, locales } = state;
  const filesState = useAttachments(page.page_files);
  const imagesState = useImageGrid(page.page_images, true);
  const [tagsState, tagsDispatch] = useTags(
    page.tags_and_suggestions,
    page.enabled_tags
  );
  const tabs = tabsList(state);
  const [tab, setTab] = useState(initialTab(tabs));
  const errorToast = useToastStore((state) => state.error);
  const noticeToast = useToastStore((state) => state.notice);

  const params = () => {
    return pageParams(state, {
      files: filesState,
      images: imagesState,
      tags: tagsState
    });
  };

  useEffect(() => {
    const pageUrl =
      `/admin/${locale}/pages/` +
      (page.id ? `${page.id}/edit` : "new") +
      `#${tab}`;
    if (history) {
      history.replaceState(null, "", pageUrl);
    }
  }, [page.id, locale, tab]);

  const handlePreview = (evt: React.MouseEvent) => {
    evt.preventDefault();
    openPreview(`/${locale}/pages/preview`, {
      page_id: `${page.id}`,
      preview_page: JSON.stringify(params())
    });
  };

  const handleSubmit = (evt: React.MouseEvent) => {
    evt.preventDefault();
    let method = postJson;
    let url = `/admin/${locale}/pages.json`;
    const data = {
      page: pageParams(state, {
        files: filesState,
        images: imagesState,
        tags: tagsState
      })
    };

    if (page.id) {
      method = putJson;
      url = `/admin/${locale}/pages/${page.id}.json`;
    }

    method(url, data)
      .then(() => {
        noticeToast("Your changes were saved");
      })
      .catch(() => {
        errorToast("An error occured while saving your changes.");
      });
  };

  return (
    <Form ref={formRef} state={state}>
      <main>
        <PageDescription state={state} dispatch={dispatch}>
          <Tabs tabs={tabs} tab={tab} setTab={setTab} />
        </PageDescription>
        <div className="content">
          <TabPanel active={tab == "content"}>
            <Content
              state={state}
              dispatch={dispatch}
              tagsState={tagsState}
              tagsDispatch={tagsDispatch}
            />
          </TabPanel>
          <TabPanel active={tab == "unconfigured-content"}>
            <UnconfiguredContent state={state} dispatch={dispatch} />
          </TabPanel>
          <TabPanel active={tab == "images"}>
            <Images locale={locale} locales={locales} state={imagesState} />
          </TabPanel>
          <TabPanel active={tab == "files"}>
            <Files locale={locale} locales={locales} state={filesState} />
          </TabPanel>
          <TabPanel active={tab == "metadata"}>
            <Metadata state={state} dispatch={dispatch} />
          </TabPanel>
          <div className="buttons">
            <button type="button" onClick={handlePreview}>
              Preview
            </button>
            <button type="submit" onClick={handleSubmit}>
              Save
            </button>
          </div>
        </div>
      </main>
      <aside className="sidebar">
        <Options
          state={state}
          dispatch={dispatch}
          authors={props.authors}
          statuses={props.statuses}
        />
      </aside>
    </Form>
  );
}
