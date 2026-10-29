import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/modal");
  await expect(
    page.getByRole("button", { name: "Delete project" }),
  ).toBeVisible();
});

test.describe("modal", () => {
  test("closed", async ({ page }) => {
    const section = page.locator("#modal-confirmation");
    await expect(section).toHaveScreenshot("closed.png");
  });

  test("open", async ({ page }) => {
    const section = page.locator("#modal-confirmation");
    const dialog = section.locator("dialog");
    await section.getByRole("button", { name: "Delete project" }).click();

    await expect(dialog).toBeVisible();
    await expect(page).toHaveScreenshot("open.png");
  });
});
