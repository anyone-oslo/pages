import * as Images from "../../types/Images";

type Props = {
  attributeName: (record: Images.Record) => string;
  deleted: Images.Record[];
};

export default function Deleted({ attributeName, deleted }: Props) {
  return (
    <div className="deleted">
      {deleted.map((r) => (
        <span className="deleted-image" key={r.id}>
          <input name={`${attributeName(r)}[id]`} type="hidden" value={r.id} />
          <input
            name={`${attributeName(r)}[attachment_id]`}
            type="hidden"
            value={(r.image && r.image.id) || ""}
          />
          <input
            name={`${attributeName(r)}[_destroy]`}
            type="hidden"
            value={"true"}
          />
        </span>
      ))}
    </div>
  );
}
