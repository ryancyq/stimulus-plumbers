import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

// Union the section and its open popover panel into a single clip rect.
async function screenshotWithPanel(page, sectionLocator, filename) {
  const panel = sectionLocator.locator("[popover]");
  await panel.waitFor({ state: "visible" });
  await expect(panel).toHaveCSS("transform", "matrix(1, 0, 0, 1, 0, 0)");
  const sBox = await sectionLocator.boundingBox();
  const pBox = await panel.boundingBox();
  const x = Math.min(sBox.x, pBox.x);
  const y = Math.min(sBox.y, pBox.y);
  const right = Math.max(sBox.x + sBox.width, pBox.x + pBox.width);
  const bottom = Math.max(sBox.y + sBox.height, pBox.y + pBox.height);
  await expect(page).toHaveScreenshot(filename, {
    clip: { x, y, width: right - x, height: bottom - y },
  });
}

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/popover/combobox");
  await page.waitForSelector("input[aria-label='Birthday']");
});

test.describe("combobox", () => {
  test("date — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date")).toHaveScreenshot(
      "date-closed.png",
    );
  });

  test("time — closed", async ({ page }) => {
    await expect(page.locator("#combobox-time")).toHaveScreenshot(
      "time-closed.png",
    );
  });

  test("dropdown — closed", async ({ page }) => {
    await expect(page.locator("#combobox-dropdown")).toHaveScreenshot(
      "dropdown-closed.png",
    );
  });

  test("typeahead — closed", async ({ page }) => {
    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot(
      "typeahead-closed.png",
    );
  });

  test("date — open", async ({ page }) => {
    const section = page.locator("#combobox-date");
    await section.getByRole("combobox", { name: "Birthday" }).click();
    await screenshotWithPanel(page, section, "date-open.png");
  });

  test("time — open", async ({ page }) => {
    const section = page.locator("#combobox-time");
    await section.getByRole("combobox", { name: "Meeting Time" }).click();
    await screenshotWithPanel(page, section, "time-open.png");
  });

  test("dropdown — open", async ({ page }) => {
    const section = page.locator("#combobox-dropdown");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "dropdown-open.png");
  });

  test("typeahead — open", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).click();
    await screenshotWithPanel(page, section, "typeahead-open.png");
  });

  test("dropdown — active option", async ({ page }) => {
    const section = page.locator("#combobox-dropdown");
    const control = section.getByRole("combobox", { name: "Country" });
    await control.click();
    await control.press("ArrowDown");
    await expect(
      section.locator("[role='option'][aria-selected='true']"),
    ).toHaveCount(1);
    await screenshotWithPanel(page, section, "dropdown-active.png");
  });

  test("typeahead — filtered", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).fill("Se");
    await expect(section.getByRole("option")).toHaveCount(1);
    await screenshotWithPanel(page, section, "typeahead-filtered.png");
  });

  test("typeahead — no results", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).fill("zzz");
    await expect(section.getByRole("status")).toHaveText("No results");
    await screenshotWithPanel(page, section, "typeahead-no-results.png");
  });

  test("typeahead remote — results", async ({ page }) => {
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(section.getByRole("option")).toHaveCount(2);
    await screenshotWithPanel(page, section, "typeahead-remote-results.png");
  });

  test("typeahead remote — loading", async ({ page }) => {
    await page.route("**/combobox/cities?*", () => {});
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(section.getByRole("status")).toHaveText("Loading…");
    await screenshotWithPanel(page, section, "typeahead-remote-loading.png");
  });

  test("typeahead remote — error", async ({ page }) => {
    await page.route("**/combobox/cities?*", (route) =>
      route.fulfill({ status: 500, body: "Server error" }),
    );
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(section.getByRole("status")).toHaveText(
      "Results could not be loaded",
    );
    await screenshotWithPanel(page, section, "typeahead-remote-error.png");
  });

  test("preselected — closed", async ({ page }) => {
    await expect(page.locator("#combobox-preselected")).toHaveScreenshot(
      "preselected-closed.png",
    );
  });

  test("preselected — open", async ({ page }) => {
    const section = page.locator("#combobox-preselected");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "preselected-open.png");
  });

  test("dropdown grouped — open", async ({ page }) => {
    const section = page.locator("#combobox-dropdown-grouped");
    // Centered, so the panel always opens below the field.
    await section.evaluate((element) =>
      element.scrollIntoView({ block: "center" }),
    );
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "dropdown-grouped-open.png");
  });

  test("disabled option — open", async ({ page }) => {
    const section = page.locator("#combobox-disabled-option");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "disabled-option-open.png");
  });

  test("date error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date-error")).toHaveScreenshot(
      "date-error-closed.png",
    );
  });

  test("date error — open", async ({ page }) => {
    const section = page.locator("#combobox-date-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "date-error-open.png");
  });

  test("time error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-time-error")).toHaveScreenshot(
      "time-error-closed.png",
    );
  });

  test("time error — open", async ({ page }) => {
    const section = page.locator("#combobox-time-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "time-error-open.png");
  });

  test("dropdown error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-dropdown-error")).toHaveScreenshot(
      "dropdown-error-closed.png",
    );
  });

  test("dropdown error — focused", async ({ page }) => {
    const section = page.locator("#combobox-dropdown-error");
    await section.getByRole("combobox").focus();
    await expect(
      section.locator("[data-controller~='combobox']"),
    ).not.toHaveCSS("box-shadow", "none");
    await expect(section).toHaveScreenshot("dropdown-error-focused.png");
  });

  test("dropdown error — open", async ({ page }) => {
    const section = page.locator("#combobox-dropdown-error");
    await section.getByRole("combobox").click();
    await screenshotWithPanel(page, section, "dropdown-error-open.png");
  });

  test("typeahead error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-typeahead-error")).toHaveScreenshot(
      "typeahead-error-closed.png",
    );
  });

  test("typeahead error — open", async ({ page }) => {
    const section = page.locator("#combobox-typeahead-error");
    await section.getByRole("combobox").click();
    await screenshotWithPanel(page, section, "typeahead-error-open.png");
  });

  test("modal — closed", async ({ page }) => {
    await expect(page.locator("#combobox-modal")).toHaveScreenshot(
      "modal-closed.png",
    );
  });

  test("modal — open", async ({ page }) => {
    const section = page.locator("#combobox-modal");
    const dialog = section.locator("dialog");
    await section
      .getByRole("button", { name: "Choose shipping country" })
      .click();
    await expect(dialog).toHaveAttribute("open", "");
    await dialog.getByRole("combobox", { name: "Shipping country" }).click();
    await dialog.locator("[popover]").waitFor({ state: "visible" });
    await expect(page).toHaveScreenshot("modal-open.png");
  });
});

test.describe("combobox — forced colors", () => {
  test.skip(
    ({ browserName }) => browserName !== "chromium",
    "Only Chromium emulates forced colors",
  );

  test("dropdown — active option", async ({ page }) => {
    await page.emulateMedia({ forcedColors: "active" });
    const section = page.locator("#combobox-dropdown");
    const control = section.getByRole("combobox", { name: "Country" });
    await control.click();
    await control.press("ArrowDown");
    const active = section.locator("[role='option'][aria-selected='true']");
    await expect(active).toHaveCSS("outline-style", "solid");
    await screenshotWithPanel(
      page,
      section,
      "dropdown-active-forced-colors.png",
    );
  });
});
