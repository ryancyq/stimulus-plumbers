import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/checklist");
  await page.waitForSelector("[role='group']");
});

test.describe("checklist", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#checklist-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test("with description", async ({ page }) => {
    await expect(page.locator("#checklist-with-description")).toHaveScreenshot(
      "with-description.png",
    );
  });

  test("read-only", async ({ page }) => {
    await expect(page.locator("#checklist-read-only")).toHaveScreenshot(
      "read-only.png",
    );
  });

  test("toggled via click", async ({ page }) => {
    const item = page
      .locator("#checklist-default input[type='checkbox']")
      .first();
    await item.click();
    await expect(page.locator("#checklist-default")).toHaveScreenshot(
      "default-toggled.png",
    );
  });

  test("select all - mixed", async ({ page }) => {
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-mixed.png",
    );
  });

  test("select all - all checked", async ({ page }) => {
    const item = page
      .locator("#checklist-select-all")
      .getByRole("checkbox", { name: "Walk the dog" });
    await item.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-all-checked.png",
    );
  });

  test("select all - all unchecked", async ({ page }) => {
    const item = page
      .locator("#checklist-select-all")
      .getByRole("checkbox", { name: "Buy milk" });
    await item.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-all-unchecked.png",
    );
  });

  test("select all - click to check all", async ({ page }) => {
    const master = page.locator(
      "#checklist-select-all [data-checklist-target='master']",
    );
    await master.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-check-all.png",
    );
  });

  test("select all - click to uncheck all", async ({ page }) => {
    const master = page.locator(
      "#checklist-select-all [data-checklist-target='master']",
    );
    await master.click();
    await master.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-uncheck-all.png",
    );
  });
});
