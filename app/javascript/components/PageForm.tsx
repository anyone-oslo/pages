import React, { useEffect } from "react";

import { putJson, postJson } from "../lib/request";
import useToastStore from "../stores/useToastStore";
import * as Pages from "../types/Pages";
import * as Template from "../types/Template";
import { Locale } from "../types";

import { openPreview } from "./PageForm/preview";
import useAttachments from "./Attachments/useAttachments";
import useImageGrid from "./ImageGrid/useImageGrid";
import useTags from "./TagEditor/useTags";
import usePage from "./PageForm/usePage";
import useTabs from "./PageForm/useTabs";
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
  page: Pages.SerializedResource;
  templates: Template.Config[];
  authors: Pages.Author[];
  statuses: Pages.StatusLabels;
}

export default function PageForm(props: Props) {
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
  const [tabs, tab, setTab] = useTabs(state);

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
    const parentParam = page.parent_page_id
      ? `?parent=${page.parent_page_id}`
      : "";
    const pageUrl =
      `/admin/${locale}/pages/` +
      (page.id ? `${page.id}/edit` : `new${parentParam}`) +
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
      .then((response: Pages.SerializedResource) => {
        dispatch({ type: "setPage", payload: response });
        if (response.errors && response.errors.length > 0) {
          errorToast("A validation error prevented the page from being saved.");
        } else {
          filesState.update(response.page_files);
          imagesState.update(response.page_images);
          tagsDispatch({
            type: "update",
            payload: {
              tags: response.tags_and_suggestions,
              enabled: response.enabled_tags
            }
          });
          noticeToast("Your changes were saved");
        }
      })
      .catch(() => {
        errorToast("An error occured while saving your changes.");
      });
  };

  return (
    <Form state={state}>
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
