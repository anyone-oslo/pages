export function csrfToken() {
  return document.querySelector("[name=csrf-token]").content;
}

function jsonFetchOptions() {
  return({ method: "POST",
           headers: { "Content-Type": "application/json; charset=utf-8",
                      "X-CSRF-Token": csrfToken() } });
}

export async function post(url, data) {
  const options = { ...jsonFetchOptions(), method: "POST" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}

export async function put(url, data) {
  const options = { ...jsonFetchOptions(), method: "PUT" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}
