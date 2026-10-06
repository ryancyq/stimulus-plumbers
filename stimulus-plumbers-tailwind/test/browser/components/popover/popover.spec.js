import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover");
  await page.waitForSelector("#popover-default [data-controller='popover']");
});

async function assertInViewport(page, locator) {
  await expect(locator).toHaveCSS("transform", "matrix(1, 0, 0, 1, 0, 0)");
  const box = await locator.boundingBox();
  const viewport = page.viewportSize();

  expect(box).not.toBeNull();
  expect(viewport).not.toBeNull();
  expect(box.x).toBeGreaterThanOrEqual(-1);
  expect(box.y).toBeGreaterThanOrEqual(-1);
  expect(box.x + box.width).toBeLessThanOrEqual(viewport.width + 1);
  expect(box.y + box.height).toBeLessThanOrEqual(viewport.height + 1);
}

async function topmostPopoverAt(page, box) {
  return page.evaluate(
    ({ x, y }) => document.elementFromPoint(x, y)?.closest("[popover]")?.id,
    { x: box.x + box.width / 2, y: box.y + box.height / 2 },
  );
}

test.describe("popover", () => {
  test("popovertarget opens the panel without Stimulus", async ({ page }) => {
    const section = page.locator("#popover-default");
    const panel = section.locator("[data-popover-target='panel']");
    await section
      .locator("[data-controller='popover']")
      .evaluate((element) => element.removeAttribute("data-controller"));

    await section.getByRole("button", { name: "Open menu" }).click();
    await expect(panel).toBeVisible();
  });

  test("opens from a consumer-owned source without moving focus", async ({
    page,
  }) => {
    const section = page.locator("#popover-behavior");
    const source = section.getByRole("textbox", {
      name: "Consumer-owned source",
    });

    await source.click();
    await expect(section.locator("#popover-focus-panel")).toBeVisible();
    await expect(source).toBeFocused();
  });

  test("clicking a consumer-owned source keeps its panel open", async ({
    page,
  }) => {
    const section = page.locator("#popover-behavior");
    const source = section.getByRole("textbox", {
      name: "Consumer-owned source",
    });
    const panel = section.locator("#popover-focus-panel");

    await source.click();
    await expect(panel).toBeVisible();
    await source.click();
    await expect(panel).toBeVisible();
  });

  test("Escape closes and resets aria-expanded", async ({ page }) => {
    const section = page.locator("#popover-behavior");
    const source = section.getByRole("button", { name: "Lifecycle dialog" });
    const panel = section.locator("#popover-behavior-panel");

    await source.click();
    await expect(source).toHaveAttribute("aria-expanded", "true");
    await page.keyboard.press("Escape");
    await expect(panel).not.toBeVisible();
    await expect(source).toHaveAttribute("aria-expanded", "false");
  });

  test("clicking outside light-dismisses the panel", async ({ page }) => {
    const section = page.locator("#popover-behavior");
    const panel = section.locator("#popover-behavior-panel");

    await section.getByRole("button", { name: "Lifecycle dialog" }).click();
    await expect(panel).toBeVisible();
    await section.locator("h2").click();
    await expect(panel).not.toBeVisible();
  });

  test("cancelling before-open keeps the panel closed", async ({ page }) => {
    const section = page.locator("#popover-behavior");
    const source = section.getByRole("button", { name: "Lifecycle dialog" });
    const panel = section.locator("#popover-behavior-panel");
    await panel.evaluate((element) => {
      element.addEventListener(
        "popover:before-open",
        (event) => event.preventDefault(),
        { once: true },
      );
    });

    await source.click();
    await expect(panel).not.toBeVisible();
    await expect(source).toHaveAttribute("aria-expanded", "false");
  });

  test("reports the native invoker as the event source", async ({ page }) => {
    const section = page.locator("#popover-behavior");
    const source = section.getByRole("button", { name: "Lifecycle dialog" });
    const panel = section.locator("#popover-behavior-panel");
    const reportedSource = panel.evaluate(
      (element, trigger) =>
        new Promise((resolve) => {
          element.addEventListener(
            "popover:opened",
            (event) => resolve(event.detail.source === trigger),
            { once: true },
          );
        }),
      await source.elementHandle(),
    );

    await source.click();
    expect(await reportedSource).toBe(true);
  });
});

test.describe("nested", () => {
  test("keeps the nested panel on top", async ({ page }) => {
    const section = page.locator("#popover-nested");
    const outer = section.locator("#popover-outer-panel");
    const inner = outer.locator("#popover-inner-panel");

    await section.getByRole("button", { name: "Open outer popover" }).click();
    await expect(outer).toBeVisible();
    await outer.getByRole("button", { name: "Open nested popover" }).click();
    await expect(inner).toBeVisible();

    const innerBox = await inner.boundingBox();
    await expect
      .poll(() => topmostPopoverAt(page, innerBox))
      .toBe("popover-inner-panel");
  });

  test("Escape closes nested panels one at a time", async ({ page }) => {
    const section = page.locator("#popover-nested");
    const outer = section.locator("#popover-outer-panel");
    const inner = outer.locator("#popover-inner-panel");

    await section.getByRole("button", { name: "Open outer popover" }).click();
    await outer.getByRole("button", { name: "Open nested popover" }).click();
    await page.keyboard.press("Escape");
    await expect(inner).not.toBeVisible();
    await expect(outer).toBeVisible();
    await page.keyboard.press("Escape");
    await expect(outer).not.toBeVisible();
  });
});

test.describe("positioning", () => {
  test.beforeEach(async ({ page }) => {
    test.skip(
      !(await page.evaluate(() => CSS.supports("position-area", "block-end"))),
      "Needs CSS anchor positioning.",
    );
  });

  test("flips a packaged source's panel at the viewport edge", async ({
    page,
  }) => {
    const section = page.locator("#popover-viewport-edge");
    const source = section.getByRole("button", { name: "Viewport edge" });
    const panel = section.locator("#popover-edge-panel");
    await source.evaluate((element) => {
      const { bottom } = element.getBoundingClientRect();
      window.scrollBy(0, bottom - window.innerHeight + 1);
    });
    await source.click();

    await expect(panel).toBeVisible();
    await assertInViewport(page, panel);
    const [sourceBox, panelBox] = await Promise.all([
      source.boundingBox(),
      panel.boundingBox(),
    ]);
    expect(panelBox.y).toBeLessThan(sourceBox.y);
  });

  test("anchors to a programmatic source passed through the controller", async ({
    page,
  }) => {
    const section = page.locator("#popover-programmatic");
    const panel = section.locator("#popover-programmatic-panel");

    await section.getByRole("textbox", { name: "Programmatic source" }).click();
    await expect(panel).toBeVisible();
    await expect(panel).toHaveCSS("position-anchor", "auto");
    await assertInViewport(page, panel);
  });

  test("stays reachable in a scroll container with a transformed ancestor", async ({
    page,
  }) => {
    const container = page.locator("#popover-scroll-container");
    const panel = container.locator("#popover-scroll-panel");
    await expect
      .poll(() =>
        container.evaluate(
          (element) => element.scrollHeight > element.clientHeight,
        ),
      )
      .toBe(true);
    await container.evaluate((element) =>
      element.scrollTo({ top: element.scrollHeight }),
    );

    await container.getByRole("button", { name: "Scroll container" }).click();
    await expect(panel).toBeVisible();
    await expect(panel).toHaveCSS("position-anchor", "auto");
    await assertInViewport(page, panel);
  });

  test("keeps logical placement in RTL and vertical writing modes", async ({
    page,
  }) => {
    const rtl = page.locator("#popover-rtl");
    const rtlPanel = rtl.locator("#popover-rtl-panel");
    await rtl.getByRole("button", { name: "RTL source" }).click();
    await expect(rtlPanel).toBeVisible();
    await expect(rtlPanel).toHaveCSS("position-area", "end span-end");
    await assertInViewport(page, rtlPanel);
    await page.keyboard.press("Escape");

    const vertical = page.locator("#popover-vertical");
    const verticalPanel = vertical.locator("#popover-vertical-panel");
    await vertical.getByRole("button", { name: "Vertical source" }).click();
    await expect(verticalPanel).toBeVisible();
    await expect(verticalPanel).toHaveCSS("position-area", "inline-end");
    await assertInViewport(page, verticalPanel);
  });

  test("keeps long content scrollable inside the viewport", async ({
    page,
  }) => {
    const section = page.locator("#popover-long-content");
    const panel = section.locator("#popover-long-panel");
    await section.getByRole("button", { name: "Long content" }).click();

    await expect(panel).toBeVisible();
    await assertInViewport(page, panel);
    await expect
      .poll(() =>
        panel.evaluate(
          (element) => element.scrollHeight > element.clientHeight,
        ),
      )
      .toBe(true);
  });

  test("keeps every placement inside the viewport", async ({ page }) => {
    const section = page.locator("#popover-placement-cases");
    const placements = [
      "block_end_start",
      "block_end",
      "block_end_end",
      "block_start_start",
      "block_start",
      "block_start_end",
      "inline_start",
      "inline_end",
    ];

    for (const placement of placements) {
      const panelId = `popover-${placement}-panel`;
      const panel = section.locator(`#${panelId}`);
      await section.locator(`button[popovertarget="${panelId}"]`).click();
      await expect(panel).toBeVisible();
      await assertInViewport(page, panel);
      await page.keyboard.press("Escape");
    }
  });
});

test.describe("in a native dialog", () => {
  async function openDialogPopover(page) {
    const section = page.locator("#popover-in-dialog");
    const dialog = section.locator("dialog");
    const source = dialog.getByRole("button", { name: "Dialog popover" });
    const panel = dialog.locator("#popover-dialog-panel");

    await section.getByRole("button", { name: "Open popover dialog" }).click();
    await expect(dialog).toHaveAttribute("open", "");
    await source.focus();
    await page.keyboard.press("Enter");
    await expect(panel).toBeVisible();
    return { dialog, source, panel };
  }

  test("anchors above the dialog", async ({ page, browserName }) => {
    test.fail(
      browserName === "webkit",
      "WebKit offsets an anchored popover by the document scroll inside a native dialog.",
    );
    const { source, panel } = await openDialogPopover(page);

    const [sourceBox, panelBox] = await Promise.all([
      source.boundingBox(),
      panel.boundingBox(),
    ]);
    expect(panelBox.y).toBeGreaterThanOrEqual(
      sourceBox.y + sourceBox.height - 1,
    );
    await assertInViewport(page, panel);
    await expect
      .poll(() => topmostPopoverAt(page, panelBox))
      .toBe("popover-dialog-panel");
  });

  test("Escape closes the popover before the dialog", async ({ page }) => {
    const { dialog, source, panel } = await openDialogPopover(page);

    await page.keyboard.press("Escape");
    await expect(panel).not.toBeVisible();
    await expect(dialog).toHaveAttribute("open", "");
    await expect(source).toBeFocused();
    await page.keyboard.press("Escape");
    await expect(dialog).not.toHaveAttribute("open", "");
  });

  test("Escape closes the popover first when focus is on the body", async ({
    page,
  }) => {
    const { dialog, panel } = await openDialogPopover(page);
    await page.evaluate(() => document.activeElement.blur());

    await page.keyboard.press("Escape");
    await expect(panel).not.toBeVisible();
    await expect(dialog).toHaveAttribute("open", "");
  });
});
