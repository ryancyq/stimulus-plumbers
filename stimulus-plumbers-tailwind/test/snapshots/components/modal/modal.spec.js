import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/modal");
  await page.waitForSelector("#modal-confirmation-dialog", {
    state: "attached",
  });
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

    await expect(dialog).toHaveAttribute("open", "");
    await expect(section.getByRole("button", { name: "Cancel" })).toBeFocused();
    await expect(page).toHaveScreenshot("open.png");
  });
});
