import { test, expect } from "@playwright/test";
import { screenshotWithPanel, settled } from "../../../support/playwright.js";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

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

  test("time — selected, hour column focused", async ({ page }) => {
    const section = page.locator("#combobox-time-selected");
    const control = section.getByRole("combobox", { name: "Standup" });
    await control.click();
    await control.press("ArrowDown");
    await screenshotWithPanel(page, section, "time-selected-focused.png");
  });

  test("time range — open", async ({ page }) => {
    const section = page.locator("#combobox-time-range");
    await section.getByRole("combobox", { name: "Opening" }).click();
    await screenshotWithPanel(page, section, "time-range-open.png");
  });

  test("datetime — open", async ({ page }) => {
    const section = page.locator("#combobox-datetime");
    await section.getByRole("combobox", { name: "Booking" }).click();
    await screenshotWithPanel(page, section, "datetime-open.png");
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
    await screenshotWithPanel(page, section, "dropdown-active.png");
  });

  test("typeahead — filtered", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).fill("Se");
    await screenshotWithPanel(page, section, "typeahead-filtered.png");
  });

  test("typeahead — no results", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).fill("zzz");
    await expect(section.getByText("No results")).toBeVisible();
    await screenshotWithPanel(page, section, "typeahead-no-results.png");
  });

  test("typeahead remote — results", async ({ page }) => {
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(section.getByRole("option").last()).toBeVisible();
    await screenshotWithPanel(page, section, "typeahead-remote-results.png");
  });

  test("typeahead remote — loading", async ({ page }) => {
    await page.route("**/combobox/cities?*", () => {});
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(section.getByText("Loading…")).toBeVisible();
    await screenshotWithPanel(page, section, "typeahead-remote-loading.png");
  });

  test("typeahead remote — error", async ({ page }) => {
    await page.route("**/combobox/cities?*", (route) =>
      route.fulfill({ status: 500, body: "Server error" }),
    );
    const section = page.locator("#combobox-typeahead-remote");
    await section.getByRole("combobox", { name: "Remote city" }).fill("Se");
    await expect(
      section.getByText("Results could not be loaded"),
    ).toBeVisible();
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
    // Centered; the panel opens below the field.
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

  test("date selected — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date-selected")).toHaveScreenshot(
      "date-selected-closed.png",
    );
  });

  test("date selected — open from the icon", async ({ page }) => {
    const section = page.locator("#combobox-date-selected");
    await section.locator("#deadline + [aria-hidden='true']").click();
    await screenshotWithPanel(page, section, "date-selected-open.png");
  });

  test("date selected — calendar focused", async ({ page }) => {
    const section = page.locator("#combobox-date-selected");
    await section.getByRole("combobox", { name: "Deadline" }).click();
    await page.keyboard.press("ArrowDown");
    await screenshotWithPanel(
      page,
      section,
      "date-selected-calendar-focused.png",
    );
  });

  test("date selected — next month", async ({ page }) => {
    const section = page.locator("#combobox-date-selected");
    await section.getByRole("combobox", { name: "Deadline" }).click();
    await page.keyboard.press("ArrowDown");
    await page.keyboard.press("PageDown");
    await screenshotWithPanel(page, section, "date-selected-next-month.png");
  });

  test("date selected — tabbed out", async ({ page }) => {
    const section = page.locator("#combobox-date-selected");
    const input = section.getByRole("combobox", { name: "Deadline" });
    await input.click();
    await page.keyboard.press("ArrowDown");
    await page.keyboard.press("Tab");
    await expect(section.locator("[popover]")).toBeHidden();
    await expect(section).toHaveScreenshot("date-selected-tabbed-out.png");
  });

  test("date selected — chosen", async ({ page }) => {
    const section = page.locator("#combobox-date-selected");
    const input = section.getByRole("combobox", { name: "Deadline" });
    await input.click();
    await page.keyboard.press("ArrowDown");
    await page.keyboard.press("ArrowRight");
    await page.keyboard.press("Enter");
    await expect(section.locator("[popover]")).toBeHidden();
    await expect(section).toHaveScreenshot("date-selected-chosen.png");
  });

  test("date in a modal — open", async ({ page }) => {
    const section = page.locator("#combobox-date-modal");
    const dialog = section.locator("dialog");
    await section.getByRole("button", { name: "Plan a trip" }).click();
    await expect(dialog).toBeVisible();
    await settled(section);
    const input = dialog.getByRole("combobox", { name: "Departure" });
    await input.focus();
    await expect(dialog.locator("[popover]")).toBeHidden();
    await page.keyboard.press("ArrowDown");
    await settled(section);
    await screenshotWithPanel(page, dialog, "date-modal-open.png");
  });

  test("time in a modal — open", async ({ page }) => {
    const section = page.locator("#combobox-time-modal");
    const dialog = section.locator("dialog");
    await section.getByRole("button", { name: "Book a call" }).click();
    await expect(dialog).toBeVisible();
    await settled(section);
    const input = dialog.getByRole("combobox", { name: "Call" });
    await input.focus();
    await expect(dialog.locator("[popover]")).toBeHidden();
    await page.keyboard.press("ArrowDown");
    await settled(section);
    await screenshotWithPanel(page, dialog, "time-modal-open.png");
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
    await expect(dialog).toBeVisible();
    await settled(section);
    await dialog.getByRole("combobox", { name: "Shipping country" }).click();
    await dialog.locator("[popover]").waitFor({ state: "visible" });
    await settled(section);
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
