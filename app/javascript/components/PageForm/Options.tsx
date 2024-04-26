import React, { useState, ChangeEvent } from "react";

import LabelledField from "../LabelledField";
import DateTimeSelect from "../DateTimeSelect";
import { errorsOn } from "./usePage";

interface OptionsProps {
  state: PageForm.State;
  dispatch: (action: PageForm.Action) => void;
  authors: Page.Author[];
  statuses: Page.StatusLabels;
}

export default function Options(props: OptionsProps) {
  const { state, dispatch, authors, statuses } = props;

  const { page, locale, templates } = state;

  const [showAdvanced, setShowAdvanced] = useState(false);

  const published = page.status == 2;
  const autopublish = published && page.published_at > new Date();
  const url = page.urls[locale];

  const handleChange =
    (attr: string) =>
    (evt: ChangeEvent<HTMLInputElement> | ChangeEvent<HTMLSelectElement>) => {
      dispatch({ type: "update", payload: { [attr]: evt.target.value } });
    };

  const handleChecked =
    (attr: string) => (evt: ChangeEvent<HTMLInputElement>) => {
      dispatch({ type: "update", payload: { [attr]: evt.target.checked } });
    };

  const changePublishedAt = (value: Date) => {
    dispatch({ type: "update", payload: { published_at: value } });
  };

  const toggleAdvanced = (evt: React.MouseEvent) => {
    evt.preventDefault();
    setShowAdvanced(!showAdvanced);
  };

  return (
    <div className="page-options">
      <LabelledField
        htmlFor="page_status"
        label="Status"
        errors={errorsOn(page, "status")}>
        <select
          id="page_status"
          name="page[status]"
          onChange={handleChange("status")}
          value={page.status}>
          {Object.keys(statuses).map((id) => (
            <option key={id} value={id}>
              {statuses[id]}
            </option>
          ))}
        </select>
      </LabelledField>
      {published && (
        <div>
          <LabelledField label="Date" errors={errorsOn(page, "published_at")}>
            <DateTimeSelect
              name={"page[published_at]"}
              onChange={changePublishedAt}
              value={page.published_at}
            />
          </LabelledField>
          {autopublish && <p>This page will publish later</p>}
        </div>
      )}
      <LabelledField
        htmlFor="page_user_id"
        label="Author"
        errors={errorsOn(page, "user_id")}>
        <select
          id="page_user_id"
          name="page[user_id]"
          onChange={handleChange("user_id")}
          value={page.user_id}>
          {authors.map((u) => (
            <option key={u[1]} value={u[1]}>
              {u[0]}
            </option>
          ))}
        </select>
      </LabelledField>
      <LabelledField label="Pin to top">
        <label className="check-box">
          <input
            name="page[pinned]"
            type="checkbox"
            onChange={handleChecked("pinned")}
            checked={page.pinned}
          />{" "}
          Make post featured
        </label>
      </LabelledField>
      TODO: Categories
      <LabelledField
        htmlFor="page_template"
        label="Template"
        errors={errorsOn(page, "template")}>
        <select
          id="page_template"
          name="page[template]"
          onChange={handleChange("template")}
          value={page.template}>
          {templates.map((t) => (
            <option key={t.template_name} value={t.template_name}>
              {t.name}
            </option>
          ))}
        </select>
      </LabelledField>
      <p>
        <a href="#" onClick={toggleAdvanced}>
          Advanced options
        </a>
      </p>
      {showAdvanced && (
        <React.Fragment>
          <LabelledField label="Subpages">
            <label className="check-box">
              <input
                name="page[feed_enabled]"
                type="checkbox"
                onChange={handleChecked("feed_enabled")}
                checked={page.feed_enabled}
              />{" "}
              RSS feed enabled
            </label>
            <label className="check-box">
              <input
                name="page[news_page]"
                type="checkbox"
                onChange={handleChecked("news_page")}
                checked={page.news_page}
              />{" "}
              Show in news
            </label>
          </LabelledField>
          <LabelledField
            htmlFor="page_unique_name"
            label="Unique name"
            errors={errorsOn(page, "unique_name")}>
            <input
              type="text"
              id="page_unique_name"
              name="page[unique_name]"
              value={page.unique_name}
              onChange={handleChange("unique_name")}
            />
          </LabelledField>
          <LabelledField
            htmlFor="page_redirect_to"
            label="Redirect"
            errors={errorsOn(page, "redirect_to")}>
            <input
              type="text"
              id="page_redirect_to"
              name="page[redirect_to]"
              value={page.redirect_to}
              onChange={handleChange("redirect_to")}
            />
          </LabelledField>
        </React.Fragment>
      )}
      {url && (
        <LabelledField label="Page link">
          <a href={url}>{url}</a>
        </LabelledField>
      )}
    </div>
  );
}
