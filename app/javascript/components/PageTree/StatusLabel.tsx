interface Props {
  status: number;
}

export default function StatusLabel({ status }: Props) {
  const labels = ["Draft", "Reviewed", "Published", "Hidden", "Deleted"];
  if (status != 2) {
    return <span className="status-label">({labels[status]})</span>;
  }
}
