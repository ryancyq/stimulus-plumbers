import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/ordered_list");
  await page.waitForSelector(
    "#ordered-list-editing [data-controller='reorderable']",
  );
});

const order = (list) =>
  list
    .locator("[data-reorderable-target~='item']")
    .evaluateAll((items) => items.map((item) => item.id));

test("pointer capture survives a drag past several items", async ({ page }) => {
  const list = page.locator(
    "#ordered-list-editing [data-controller='reorderable']",
  );
  const first = await list.locator("#editing-1").boundingBox();
  const third = await list.locator("#editing-3").boundingBox();
  const x = first.x + first.width / 2;

  await page.mouse.move(x, first.y + first.height / 2);
  await page.mouse.down();
  await page.mouse.move(x, third.y + third.height - 2, { steps: 20 });
  await page.mouse.up();

  expect(await order(list)).toEqual(["editing-2", "editing-3", "editing-1"]);
});
