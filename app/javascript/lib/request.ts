export function csrfToken(): string {
  const elem = document.querySelector("[name=csrf-token]");

  if (!elem) {
    return "";
  }

  return elem.getAttribute("content") || "";
}

function jsonFetchOptions() {
  return {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-CSRF-Token": csrfToken()
    }
  };
}

export async function postJson(url: string, data: Record<string, unknown>) {
  const response = await fetch(url, {
    ...jsonFetchOptions(),
    method: "POST",
    body: data ? JSON.stringify(data) : null
  });
  return response.json();
}

export async function putJson(url: string, data: Record<string, unknown>) {
  const response = await fetch(url, {
    ...jsonFetchOptions(),
    method: "PUT",
    body: data ? JSON.stringify(data) : null
  });
  return response.json();
}

export async function post(url: string, data: FormData) {
  const response = await fetch(url, {
    method: "POST",
    body: data,
    headers: { "X-CSRF-Token": csrfToken() }
  });
  return response.json();
}
