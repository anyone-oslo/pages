import * as Attachments from "../../types/Attachments";

type Props = {
  attributeName: (record: Attachments.Record) => string;
  deleted: Attachments.Record[];
};

export default function Deleted({ attributeName, deleted }: Props) {
  return (
    <div className="deleted">
      {deleted.map((r) => (
        <span className="deleted-attachment" key={r.id}>
          <input name={`${attributeName(r)}[id]`} type="hidden" value={r.id} />
          <input
            name={`${attributeName(r)}[attachment_id]`}
            type="hidden"
            value={(r.attachment && r.attachment.id) || ""}
          />
          <input
            name={`${attributeName(r)}[_destroy]`}
            type="hidden"
            value="true"
          />
        </span>
      ))}
    </div>
  );
}
