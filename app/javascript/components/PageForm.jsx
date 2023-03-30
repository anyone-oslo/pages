import React, { useEffect, useState, useRef } from "react";
import PropTypes from "prop-types";

import usePage from "./PageForm/usePage";
import Content from "./PageForm/Content";
import Metadata from "./PageForm/Metadata";
import Form from "./PageForm/Form";
import PageDescription from "./PageForm/PageDescription";
import Options from "./PageForm/Options";
import TabPanel from "./PageForm/TabPanel";
import Files from "./PageForm/Files";
import Images from "./PageForm/Images";

function tabsList(templates, templateConfig) {
  let tabs = [{ id: "content", name: "Content", enabled: true }];
  if (templates.filter(t => t.images).length > 0) {
    tabs.push({ id: "images", name: "Images", enabled: templateConfig.images });
  }
  if (templates.filter(t => t.files).length > 0) {
    tabs.push({ id: "files", name: "Files", enabled: templateConfig.files });
  }
  tabs.push({ id: "metadata", name: "Metadata", enabled: true });
  return tabs;
}

function initialTab(tabs) {
  const tabExpression = /#(.*)$/;
  if (document.location.toString().match(tabExpression)) {
    let id = document.location.toString().match(tabExpression)[1];
    const matchingTab = tabs.filter(t => t.id == id)[0];
    if (matchingTab) {
      return matchingTab.id;
    }
  }
  return tabs[0].id;
}

export default function PageForm(props) {
  const formRef = useRef(null);
  const [state, dispatch] = usePage({
    locales: props.locales,
    locale: props.locale,
    page: props.page,
    templates: props.templates
  });

  const { page, locale, locales, templates, templateConfig } = state;

  const tabs = tabsList(templates, templateConfig);

  const [tab, setTab] = useState(initialTab(tabs));

  useEffect(() => {
    const pageUrl = `/admin/${locale}/pages/` +
          (page.id ? `${page.id}/edit` : "new") + `#${tab}`;
    if (history) {
      history.replaceState(null, "", pageUrl);
    }
  }, [page.id, locale, tab]);

  const handleTabChange = (tab) => (evt) => {
    evt.preventDefault();
    setTab(tab.id);
  };

  const handlePreview = (evt) => {
    evt.preventDefault();
    console.log("preview");
  };

  const handleSubmit = (evt) => {
    evt.preventDefault();
    console.log("submit");
  };

  return (
    <Form ref={formRef} state={state}>
      <main>
        <PageDescription state={state} dispatch={dispatch}>
          <ul className="content-tabs" role="tablist">
            {tabs.map(t =>
              <li key={t.id} className={t.id == tab ? "current" : ""}>
                {!t.enabled && t.name}
                {t.enabled &&
                 <a href={`#${t.id}`}
                    onClick={handleTabChange(t)}>
                   {t.name}
                 </a>}
              </li>)}
          </ul>
        </PageDescription>
        <div className="content">
          <TabPanel active={tab == "content"}>
            <Content state={state}
                     dispatch={dispatch} />
          </TabPanel>
          <TabPanel active={tab == "images"}>
            <Images locale={locale}
                    locales={locales}
                    records={page.page_images} />
          </TabPanel>
          <TabPanel active={tab == "files"}>
            <Files locale={locale}
                   locales={locales}
                   records={page.page_files} />
          </TabPanel>
          <TabPanel active={tab == "metadata"}>
            <Metadata state={state}
                      dispatch={dispatch} />
          </TabPanel>
          <div className="buttons">
            <button type="button"
                    onClick={handlePreview}>
              Preview
            </button>
            <button type="submit"
                    onClick={handleSubmit}>
              Save
            </button>
          </div>
        </div>
      </main>
      <aside className="sidebar">
        <Options state={state}
                 dispatch={dispatch}
                 authors={props.authors}
                 statuses={props.statuses} />
      </aside>
    </Form>
  );
}

PageForm.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array,
  authors: PropTypes.array,
  statuses: PropTypes.object
};
