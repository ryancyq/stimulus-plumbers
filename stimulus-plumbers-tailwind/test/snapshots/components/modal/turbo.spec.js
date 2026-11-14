import { test, expect } from "@playwright/test";
import { settled } from "../../../support/playwright.js";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/modal/turbo");
  await page
    .locator("#modal-turbo")
    .getByRole("link", { name: "Edit profile" })
    .waitFor();
});

test.describe("turbo modal", () => {
  test("closed", async ({ page }) => {
    await expect(page.locator("#modal-turbo")).toHaveScreenshot("closed.png");
  });

  test("open", async ({ page }) => {
    const section = page.locator("#modal-turbo");
    await section.getByRole("link", { name: "Edit profile" }).click();
    const dialog = section.locator("dialog");
    await expect(dialog.getByRole("button", { name: "Save" })).toBeVisible();
    await settled(dialog);
    await expect(page).toHaveScreenshot("open.png");
  });

  test("validation error", async ({ page }) => {
    const section = page.locator("#modal-turbo");
    await section.getByRole("link", { name: "Edit profile" }).click();
    await section.getByRole("button", { name: "Save" }).click();
    await expect(section.getByText("Name is required")).toBeVisible();
    await settled(section.locator("dialog"));
    await expect(page).toHaveScreenshot("validation-error.png");
  });
});
