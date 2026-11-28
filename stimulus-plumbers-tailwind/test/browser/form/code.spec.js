import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/code");
  await page.waitForSelector("#code-default [data-controller~='input-code']");
});

test("clicking a cell puts the caret before it", async ({ page }) => {
  const section = page.locator("#code-default");
  const input = section.getByRole("textbox", { name: "Verification code" });
  const cells = section.locator("[data-input-code-target='cell']");

  await input.fill("482913");
  const cell = await cells.nth(2).boundingBox();
  await page.mouse.click(cell.x + cell.width / 2, cell.y + cell.height / 2);

  await expect(cells.nth(2)).toHaveAttribute("data-caret", "");

  await page.keyboard.type("7");

  await expect(input).toHaveValue("487913");
});
