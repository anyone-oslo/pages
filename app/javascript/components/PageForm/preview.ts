import { csrfToken } from "../../lib/request";

function buildForm(url: string, body: Record<string, string>) {
  const form = document.createElement("form");
  form.action = url;
  form.method = "POST";
  form.target = "_blank";
  for (const [name, value] of Object.entries(body)) {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    form.appendChild(input);
  }
  return form;
}

export function openPreview(url: string, body: Record<string, string>) {
  const form = buildForm(url, { authenticity_token: csrfToken(), ...body });
  document.body.appendChild(form);
  form.submit();
  document.body.removeChild(form);
}
