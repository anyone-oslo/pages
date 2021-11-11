export function copySupported () {
  return document.queryCommandSupported &&
    document.queryCommandSupported("copy");
}

export default function copyToClipboard (str) {
  const el = document.createElement("textarea");
  el.value = str;
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
}
