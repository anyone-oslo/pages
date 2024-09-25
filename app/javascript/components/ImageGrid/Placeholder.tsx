interface Props {
  src: string;
}

export default function Placeholder(props: Props) {
  if (props.src) {
    return (
      <div className="temp-image">
        <img src={props.src} />
        <span>Uploading...</span>
      </div>
    );
  } else {
    return (
      <div className="file-placeholder">
        <span>Uploading...</span>
      </div>
    );
  }
}
