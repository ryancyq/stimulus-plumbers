import { test, expect } from "@playwright/test";
import { settled } from "../../../support/playwright.js";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover/combobox");
  await page.waitForSelector("#combobox-dropdown [data-controller='combobox']");
});

// The panel starts at the field's inline-start edge, spans at least its width, and touches its block edge.
async function expectAnchoredToField(panel, field) {
  await expect(panel).toBeVisible();
  await settled(panel);
  const p = await panel.boundingBox();
  const f = await field.boundingBox();
  const rtl = await field.evaluate(
    (element) => getComputedStyle(element).direction === "rtl",
  );

  const start = rtl ? p.x + p.width - (f.x + f.width) : p.x - f.x;
  expect(Math.abs(start)).toBeLessThanOrEqual(1);
  expect(p.width).toBeGreaterThanOrEqual(f.width - 1);
  const below = Math.abs(p.y - (f.y + f.height));
  const above = Math.abs(p.y + p.height - f.y);
  expect(Math.min(below, above)).toBeLessThanOrEqual(1);
}

async function openInModal(page) {
  const section = page.locator("#combobox-modal");
  const dialog = section.locator("dialog");
  const trigger = dialog.getByRole("combobox", { name: "Shipping country" });

  await section
    .getByRole("button", { name: "Choose shipping country" })
    .click();
  await expect(dialog).toHaveAttribute("open", "");
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  return { dialog, trigger };
}

test.describe("combobox anchoring", () => {
  test.beforeEach(async ({ page }) => {
    test.skip(
      !(await page.evaluate(() => CSS.supports("position-area", "block-end"))),
      "Needs CSS anchor positioning.",
    );
  });

  test("a dropdown panel is anchored to its field group", async ({ page }) => {
    const section = page.locator("#combobox-dropdown");
    const trigger = section.getByRole("combobox", { name: "Country" });

    await trigger.click();
    await expectAnchoredToField(
      section.locator("[popover]"),
      trigger.locator(".."),
    );
  });

  test("a typeahead panel is anchored to its own field group", async ({
    page,
  }) => {
    const section = page.locator("#combobox-typeahead");
    const trigger = section.getByRole("combobox", { name: "City" });

    await trigger.click();
    await expectAnchoredToField(
      section.locator("[popover]"),
      trigger.locator(".."),
    );
  });

  test("a form field panel is anchored to the visible field", async ({
    page,
  }) => {
    const section = page.locator("#combobox-dropdown-error");
    const root = section.locator("[data-controller~='combobox']");

    await section.getByRole("combobox").click();
    await expectAnchoredToField(section.locator("[popover]"), root);
  });

  test("an RTL panel is anchored to its field's inline start", async ({
    page,
  }) => {
    const section = page.locator("#combobox-dropdown");
    const trigger = section.getByRole("combobox", { name: "Country" });
    await page.evaluate(() => (document.documentElement.dir = "rtl"));

    await trigger.click();
    await expectAnchoredToField(
      section.locator("[popover]"),
      trigger.locator(".."),
    );
  });

  test("a panel in a modal is anchored to its field", async ({ page }) => {
    const { dialog, trigger } = await openInModal(page);

    await expectAnchoredToField(
      dialog.locator("[popover]"),
      trigger.locator(".."),
    );
  });

  test("keeps the panel inside a 320px viewport", async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 568 });
    const section = page.locator("#combobox-dropdown");
    const panel = section.locator("[popover]");

    await section.getByRole("combobox", { name: "Country" }).click();
    await expect(panel).toBeVisible();
    await settled(panel);
    const box = await panel.boundingBox();
    expect(box.x).toBeGreaterThanOrEqual(-1);
    expect(box.x + box.width).toBeLessThanOrEqual(321);
    await expect(
      section.getByRole("option", { name: "United States" }),
    ).toBeInViewport();
  });
});

test.describe("pointer", () => {
  test("clicking a select-only trigger focuses it and opens the panel", async ({
    page,
  }) => {
    const trigger = page
      .locator("#combobox-dropdown")
      .getByRole("combobox", { name: "Country" });

    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(trigger).toBeFocused();
  });

  test("clicking the icon focuses the trigger and opens the panel", async ({
    page,
  }) => {
    const section = page.locator("#combobox-dropdown");
    const trigger = section.getByRole("combobox", { name: "Country" });

    await trigger.locator("+ svg").click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(trigger).toBeFocused();
  });

  test("clicking an option keeps focus on the trigger", async ({ page }) => {
    const section = page.locator("#combobox-dropdown");
    const trigger = section.getByRole("combobox", { name: "Country" });

    await trigger.click();
    await section.getByRole("option", { name: "Canada" }).click();
    await expect(trigger).toBeFocused();
  });

  test.describe("iframe", () => {
    test.skip(
      ({ browserName }) => browserName === "firefox",
      "Firefox under Playwright fires no blur when focus enters a frame.",
    );

    test("focus moving into an iframe closes the panel", async ({ page }) => {
      const trigger = page
        .locator("#combobox-dropdown")
        .getByRole("combobox", { name: "Country" });
      // Above the field, clear of the open panel.
      const outside = page.locator("#combobox-date");
      await outside.evaluate((element) => {
        const frame = document.createElement("iframe");
        frame.title = "Outside frame";
        frame.srcdoc = '<input aria-label="Inside">';
        element.append(frame);
      });

      await trigger.click();
      await outside
        .frameLocator("iframe")
        .getByRole("textbox", { name: "Inside" })
        .click();
      await expect(trigger).toHaveAttribute("aria-expanded", "false");
    });
  });
});

test.describe("touch", () => {
  test.skip(({ isMobile }) => !isMobile, "Touch devices only.");

  test("tapping outside closes the panel", async ({ page }) => {
    const trigger = page
      .locator("#combobox-dropdown")
      .getByRole("combobox", { name: "Country" });

    await trigger.tap();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    // The page heading is outside every combobox.
    await page.locator("h1").tap();
    await expect(trigger).toHaveAttribute("aria-expanded", "false");
  });
});

test.describe("touch scrolling", () => {
  test.skip(
    ({ isMobile, browserName }) => !isMobile || browserName !== "chromium",
    "Only Chromium synthesizes touch scrolling.",
  );

  test("does not close the panel", async ({ page }) => {
    const trigger = page
      .locator("#combobox-dropdown")
      .getByRole("combobox", { name: "Country" });
    const cdp = await page.context().newCDPSession(page);

    await trigger.tap();
    await cdp.send("Input.synthesizeScrollGesture", {
      x: 20,
      y: 500,
      yDistance: -200,
      gestureSourceType: "touch",
    });
    await expect
      .poll(() => page.evaluate(() => window.scrollY))
      .toBeGreaterThan(0);
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
  });
});

test.describe("in a modal", () => {
  test("Escape in a time panel closes only the panel", async ({ page }) => {
    const section = page.locator("#combobox-time-modal");
    const dialog = section.locator("dialog");
    await section.getByRole("button", { name: "Book a call" }).click();
    await expect(dialog).toHaveAttribute("open", "");
    const input = dialog.getByRole("combobox", { name: "Call" });
    await input.focus();
    await page.keyboard.press("ArrowDown");
    await expect(dialog.getByRole("listbox", { name: "Hour" })).toBeFocused();

    await page.keyboard.press("Escape");
    await expect(input).toHaveAttribute("aria-expanded", "false");
    await expect(dialog).toHaveAttribute("open", "");
    await expect(input).toBeFocused();
  });
});
