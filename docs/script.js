const themeToggle = document.getElementById("theme-toggle");
const labels = { light: "Light", dark: "Dark" };

try {
  localStorage.removeItem("theme");
} catch {
  // Storage can be blocked. The system theme still applies.
}

function systemTheme() {
  return window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
}

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;

  if (!themeToggle) {
    return;
  }

  const next = theme === "light" ? "dark" : "light";
  themeToggle.textContent = labels[theme];
  themeToggle.setAttribute(
    "aria-label",
    `Theme: ${labels[theme]}. Activate to switch to ${labels[next]}.`
  );
}

let override = null;

function activeTheme() {
  return override ?? systemTheme();
}

applyTheme(activeTheme());

window.matchMedia("(prefers-color-scheme: light)").addEventListener("change", () => {
  if (override === null) {
    applyTheme(systemTheme());
  }
});

themeToggle?.addEventListener("click", () => {
  override = activeTheme() === "light" ? "dark" : "light";
  applyTheme(override);
});
