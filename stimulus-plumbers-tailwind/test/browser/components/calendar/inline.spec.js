import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/calendar/inline");
  await page.waitForSelector("#calendar-inline-month [data-date]");
});

test.describe("touch", () => {
  test.skip(({ isMobile }) => !isMobile, "Touch projects only.");

  test("tapping a day selects it", async ({ page }) => {
    const section = page.locator("#calendar-inline-month");
    await section.locator("[data-date='2026-09-17']").tap();

    await expect(
      section.locator("td[aria-selected='true'] [data-date='2026-09-17']"),
    ).toBeVisible();
  });
});

test.describe("pointer focus", () => {
  test.skip(
    ({ browserName }) => browserName === "webkit",
    "WebKit does not focus a clicked link or button, so focus stays on body.",
  );

  for (const mode of ["stimulus", "turbo"]) {
    test(`clicking next month keeps focus on it in ${mode} mode`, async ({
      page,
    }) => {
      if (mode === "turbo") {
        await page.goto("/components/calendar/inline?navigation=turbo");
      }
      const section = page.locator("#calendar-inline-month");
      await section.locator("[data-navigation='next']").click();
      await expect(
        section.getByRole("heading", { level: 2, name: "October 2026" }),
      ).toBeVisible();

      await expect(section.locator("[data-navigation='next']")).toBeFocused();
    });
  }
});
