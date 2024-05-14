import React from "react";

import * as Attachments from "../../types/Attachments";
import { Locale } from "../../types";

import List from "../Attachments/List";

interface Props {
  locale: string;
  locales: { [index: string]: Locale };
  state: Attachments.State;
}

export default function Files(props: Props) {
  const { locale, locales, state } = props;

  return (
    <div className="page-files">
      <List
        attribute="page[page_files_attributes]"
        showEmbed={true}
        locale={locale}
        locales={locales}
        state={state}
      />
    </div>
  );
}
