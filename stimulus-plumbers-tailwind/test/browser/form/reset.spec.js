import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/reset");
  await page.waitForSelector(
    "#reset-comboboxes [data-controller~='combobox-time']",
  );
});

test("a reset button restores each combobox", async ({ page }) => {
  const section = page.locator("#reset-comboboxes");
  const country = section.getByRole("combobox", { name: "Country" });
  const standup = section.getByRole("combobox", { name: "Standup" });
  const shownTime = await standup.inputValue();

  await country.click();
  await section.getByRole("option", { name: "Australia" }).click();
  await standup.press("ArrowDown");
  await page.keyboard.press("ArrowDown");
  await page.keyboard.press("Enter");
  await expect(country).toHaveText("Australia");
  await expect(standup).not.toHaveValue(shownTime);

  await section.getByRole("button", { name: "Reset" }).click();

  await expect(country).toHaveText("Canada");
  await expect(standup).toHaveValue(shownTime);
  await expect(section.locator("input[name='country']")).toHaveValue("ca");
  await expect(section.locator("input[name='standup']")).toHaveValue("14:30");
});
