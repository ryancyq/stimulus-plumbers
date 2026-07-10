import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/timeline");
  await page.waitForSelector("[data-controller='timeline']");
});

test.describe("timeline", () => {
  test("static", async ({ page }) => {
    await expect(page.locator("#timeline-static")).toHaveScreenshot(
      "static.png",
    );
  });

  test("collapsed", async ({ page }) => {
    await expect(page.locator("#timeline-interactive")).toHaveScreenshot(
      "collapsed.png",
    );
  });

  test("expanded", async ({ page }) => {
    const trigger = page
      .locator("#timeline-interactive")
      .getByRole("button", { name: "Application UI code in Tailwind CSS" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#timeline-interactive")).toHaveScreenshot(
      "expanded.png",
    );
  });

  test("horizontal stepper", async ({ page }) => {
    await expect(page.locator("#timeline-horizontal")).toHaveScreenshot(
      "horizontal-default.png",
    );
  });

  test("grouped", async ({ page }) => {
    await expect(page.locator("#timeline-grouped")).toHaveScreenshot(
      "grouped-default.png",
    );
  });

  test("grouped horizontal", async ({ page }) => {
    await expect(page.locator("#timeline-grouped-horizontal")).toHaveScreenshot(
      "grouped-horizontal.png",
    );
  });
});
