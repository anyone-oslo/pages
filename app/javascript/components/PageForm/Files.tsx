import React from "react";
import List from "../Attachments/List";

interface FilesProps {
  locale: string;
  locales: { [index: string]: Locale };
  state: Attachments.State;
}

export default function Files(props: FilesProps) {
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
