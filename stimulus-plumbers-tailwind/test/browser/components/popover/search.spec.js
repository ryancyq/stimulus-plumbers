import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover/search");
  await page.waitForSelector(
    "#search-suggestions [data-controller~='combobox']",
  );
});

test.describe("search", () => {
  test("clicking clear keeps focus in the field where buttons take no click focus", async ({
    page,
  }) => {
    const section = page.locator("#search-suggestions");
    const field = section.getByRole("combobox", { name: "City" });

    await field.fill("Se");
    await section.getByRole("button", { name: "Clear search" }).click();
    await expect(field).toHaveValue("");
    await expect(field).toBeFocused();
  });
});
