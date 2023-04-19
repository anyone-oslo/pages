import React from "react";
import Attachments from "../Attachments";

interface FilesProps {
  locale: string;
  locales: { [index: string]: Locale };
  records: AttachmentRecord[];
}

export default function Files(props: FilesProps) {
  const { locale, locales, records } = props;

  return (
    <div className="page-files">
      <Attachments
        attribute="page[page_files_attributes]"
        showEmbed={true}
        locale={locale}
        locales={locales}
        records={records}
      />
    </div>
  );
}
