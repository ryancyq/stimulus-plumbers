import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/modal");
  await page.waitForSelector("#modal-confirmation-dialog", {
    state: "attached",
  });
});

test.describe("modal", () => {
  test("Escape dismisses and restores trigger focus", async ({ page }) => {
    const trigger = page
      .locator("#modal-confirmation")
      .getByRole("button", { name: "Delete project" });
    const dialog = page.locator("#modal-confirmation-dialog");
    await trigger.click();
    await page.keyboard.press("Escape");

    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(trigger).toBeFocused();
    await expect
      .poll(() =>
        page
          .locator("html")
          .evaluate((element) => getComputedStyle(element).overflow),
      )
      .not.toBe("hidden");
  });

  test("native dialog commands work without Stimulus actions", async ({
    page,
  }) => {
    const section = page.locator("#modal-confirmation");
    const dialog = page.locator("#modal-confirmation-dialog");
    await section.locator("[data-action]").evaluateAll((elements) => {
      elements.forEach((element) => element.removeAttribute("data-action"));
    });

    await section.getByRole("button", { name: "Delete project" }).click();
    await expect(dialog).toHaveAttribute("open", "");
    await section.getByRole("button", { name: "Cancel" }).click();
    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(
      section.getByRole("button", { name: "Delete project" }),
    ).toBeFocused();

    await section.getByRole("button", { name: "Delete project" }).click();
    await section.getByRole("button", { name: "Delete", exact: true }).click();

    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(dialog).toHaveJSProperty("returnValue", "delete");
  });

  test("uses the first focusable element when autofocus is absent", async ({
    page,
  }) => {
    const section = page.locator("#modal-no-autofocus");
    await section.getByRole("button", { name: "Open project name" }).click();

    await expect(section.locator("#modal-no-autofocus-field")).toBeFocused();
  });

  test("method dialog reports its native return value", async ({ page }) => {
    const section = page.locator("#modal-method-dialog");
    const dialog = section.locator("#modal-method-dialog-dialog");
    await section.getByRole("button", { name: "Open method dialog" }).click();
    const [returnValue] = await Promise.all([
      dialog.evaluate(
        (element) =>
          new Promise((resolve) => {
            element.addEventListener(
              "close",
              () => resolve(element.returnValue),
              { once: true },
            );
          }),
      ),
      dialog.getByRole("button", { name: "Complete" }).click(),
    ]);

    await expect(dialog).not.toHaveAttribute("open", "");
    expect(returnValue).toBe("method-result");
  });

  test("closedby any closes on Escape", async ({ page }) => {
    const section = page.locator("#modal-closedby-any");
    const dialog = section.locator("#modal-closedby-any-dialog");
    await section.getByRole("button", { name: "Open any dismissal" }).click();
    await page.keyboard.press("Escape");

    await expect(dialog).not.toHaveAttribute("open", "");
  });

  test("closedby closerequest closes on Escape", async ({ page }) => {
    const section = page.locator("#modal-closedby-closerequest");
    const dialog = section.locator("#modal-closedby-closerequest-dialog");
    await section
      .getByRole("button", { name: "Open close request dismissal" })
      .click();
    await page.keyboard.press("Escape");

    await expect(dialog).not.toHaveAttribute("open", "");
  });

  test("closedby none ignores Escape", async ({ page }) => {
    const section = page.locator("#modal-closedby-none");
    const dialog = section.locator("#modal-closedby-none-dialog");
    await section.getByRole("button", { name: "Open no dismissal" }).click();
    await page.keyboard.press("Escape");
    await expect(dialog).toHaveAttribute("open", "");

    await section.getByRole("button", { name: "Complete" }).click();
    await expect(dialog).not.toHaveAttribute("open", "");
  });

  test.describe("backdrop", () => {
    test.skip(
      ({ isMobile }) => isMobile,
      "Mobile modals are full-screen, so there is no backdrop.",
    );

    test("closedby any closes on backdrop click", async ({ page }) => {
      const section = page.locator("#modal-closedby-any");
      const dialog = section.locator("#modal-closedby-any-dialog");
      await section.getByRole("button", { name: "Open any dismissal" }).click();
      await page.mouse.click(1, 1);

      await expect(dialog).not.toHaveAttribute("open", "");
    });

    test("closedby closerequest ignores backdrop click", async ({ page }) => {
      const section = page.locator("#modal-closedby-closerequest");
      const dialog = section.locator("#modal-closedby-closerequest-dialog");
      await section
        .getByRole("button", { name: "Open close request dismissal" })
        .click();
      await page.mouse.click(1, 1);
      await expect(dialog).toHaveAttribute("open", "");

      await section.getByRole("button", { name: "Complete" }).click();
      await expect(dialog).not.toHaveAttribute("open", "");
    });

    test("closedby none ignores backdrop click", async ({ page }) => {
      const section = page.locator("#modal-closedby-none");
      const dialog = section.locator("#modal-closedby-none-dialog");
      await section.getByRole("button", { name: "Open no dismissal" }).click();
      await page.mouse.click(1, 1);
      await expect(dialog).toHaveAttribute("open", "");

      await section.getByRole("button", { name: "Complete" }).click();
      await expect(dialog).not.toHaveAttribute("open", "");
    });
  });

  test("external close reports its return value", async ({ page }) => {
    const section = page.locator("#modal-confirmation");
    const dialog = section.locator("#modal-confirmation-dialog");
    await section.getByRole("button", { name: "Delete project" }).click();
    const [closedResult] = await Promise.all([
      dialog.evaluate(
        (element) =>
          new Promise((resolve) => {
            element.addEventListener(
              "modal:closed",
              (event) => resolve(event.detail.result),
              { once: true },
            );
          }),
      ),
      dialog.evaluate((element) => element.close("external-result")),
    ]);
    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(dialog).toHaveJSProperty("returnValue", "external-result");
    expect(closedResult).toBe("external-result");
  });

  test("supports repeated open cycles without an open conflict", async ({
    page,
  }) => {
    const errors = [];
    page.on("pageerror", (error) => errors.push(error.message));
    const trigger = page
      .locator("#modal-confirmation")
      .getByRole("button", { name: "Delete project" });
    const dialog = page.locator("#modal-confirmation-dialog");

    await dialog.evaluate((element) => element.show());
    await expect(dialog).toHaveAttribute("open", "");
    await trigger.evaluate((element) => element.click());
    await expect(dialog).toHaveAttribute("open", "");
    await dialog.evaluate((element) => element.close());

    await trigger.click();
    await page
      .locator("#modal-confirmation")
      .getByRole("button", { name: "Cancel" })
      .click();
    await trigger.click();
    await expect(dialog).toHaveAttribute("open", "");
    await page
      .locator("#modal-confirmation")
      .getByRole("button", { name: "Cancel" })
      .click();

    expect(errors).toEqual([]);
  });

  test("serializes close and immediate reopen", async ({ page }) => {
    const section = page.locator("#modal-confirmation");
    const dialog = section.locator("#modal-confirmation-dialog");
    const trigger = section.getByRole("button", { name: "Delete project" });
    await trigger.click();

    const events = await section.evaluate((element) => {
      const dialog = element.querySelector("dialog");
      const trigger = element.querySelector('[data-action~="modal#open"]');
      const close = element.querySelector('[data-action~="modal#close"]');

      return new Promise((resolve) => {
        const events = [];
        ["modal:closed", "modal:before-open", "modal:opened"].forEach(
          (name) => {
            dialog.addEventListener(name, () => {
              events.push(name);
              if (name === "modal:opened") resolve(events);
            });
          },
        );

        close.click();
        trigger.click();
      });
    });

    expect(events).toEqual([
      "modal:closed",
      "modal:before-open",
      "modal:opened",
    ]);
    await expect(dialog).toHaveAttribute("open", "");
    await expect(dialog.getByRole("button", { name: "Cancel" })).toBeFocused();
  });

  test("completion reports its result", async ({ page }) => {
    const section = page.locator("#modal-confirmation");
    const dialog = section.locator("#modal-confirmation-dialog");
    await section.getByRole("button", { name: "Delete project" }).click();
    const [closedResult] = await Promise.all([
      dialog.evaluate(
        (element) =>
          new Promise((resolve) => {
            element.addEventListener(
              "modal:closed",
              (event) => resolve(event.detail.result),
              { once: true },
            );
          }),
      ),
      section.getByRole("button", { name: "Delete", exact: true }).click(),
    ]);

    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(dialog).toHaveJSProperty("returnValue", "delete");
    expect(closedResult).toBe("delete");
  });

  test.describe("long content", () => {
    const open = async (page) => {
      const dialog = page.locator("#modal-aria-label-dialog");
      await page
        .locator("#modal-aria-label")
        .getByRole("button", { name: "Open project details" })
        .click();
      await expect(dialog).toHaveAttribute("open", "");
      return { dialog, body: dialog.locator(":scope > div") };
    };
    const tolerance = (page) =>
      page.evaluate(() => Math.max(1 / window.devicePixelRatio, 0.5));

    test("keeps long content scrollable and actions visible", async ({
      page,
    }) => {
      const { dialog, body } = await open(page);

      await expect
        .poll(() =>
          body.evaluate(
            (element) => element.scrollHeight > element.clientHeight,
          ),
        )
        .toBe(true);
      await expect(dialog.locator(":scope > footer")).toBeInViewport();
      await expect
        .poll(() =>
          page
            .locator("html")
            .evaluate((element) => getComputedStyle(element).overflow),
        )
        .toBe("hidden");
    });

    test.describe("desktop", () => {
      test.skip(({ isMobile }) => isMobile, "Desktop layout only.");

      test("centers a width-constrained dialog", async ({ page }) => {
        const gutter = await page.evaluate(() =>
          Math.max(0, window.innerWidth - document.body.clientWidth),
        );
        const { dialog } = await open(page);
        const box = await dialog.boundingBox();
        const viewport = page.viewportSize();

        expect(box.width).toBeLessThanOrEqual(512);
        const expectedX = (viewport.width - gutter - box.width) / 2;
        expect(Math.abs(box.x - expectedX)).toBeLessThanOrEqual(
          await tolerance(page),
        );
      });
    });

    test.describe("mobile", () => {
      test.skip(({ isMobile }) => !isMobile, "Mobile layout only.");

      test("fills the viewport", async ({ page }) => {
        const { dialog } = await open(page);
        const box = await dialog.boundingBox();
        const viewport = page.viewportSize();
        const pixel = await tolerance(page);

        expect(Math.abs(box.width - viewport.width)).toBeLessThanOrEqual(pixel);
        expect(Math.abs(box.height - viewport.height)).toBeLessThanOrEqual(
          pixel,
        );
      });
    });

    test.describe("scroll chaining", () => {
      test.skip(
        ({ browserName, isMobile }) => browserName === "webkit" && isMobile,
        "Playwright can't dispatch wheel events in mobile WebKit.",
      );

      test("does not scroll the page past the modal body", async ({ page }) => {
        const { body } = await open(page);
        await body.evaluate((element) => {
          element.scrollTop = element.scrollHeight;
        });
        const bodyBox = await body.boundingBox();
        await page.mouse.move(
          bodyBox.x + bodyBox.width / 2,
          bodyBox.y + bodyBox.height / 2,
        );
        await page.mouse.wheel(0, 1200);

        await expect.poll(() => page.evaluate(() => window.scrollY)).toBe(0);
      });
    });
  });

  test("keeps root locking and content usable at 320px (400% reflow equivalent)", async ({
    page,
  }) => {
    await page.setViewportSize({ width: 320, height: 568 });
    const section = page.locator("#modal-aria-label");
    await section.getByRole("button", { name: "Open project details" }).click();
    const dialog = page.locator("#modal-aria-label-dialog");
    const body = dialog.locator(":scope > div");
    await expect
      .poll(() =>
        body.evaluate((element) => element.scrollHeight > element.clientHeight),
      )
      .toBe(true);
    await expect
      .poll(() =>
        page
          .locator("html")
          .evaluate((element) => getComputedStyle(element).overflow),
      )
      .toBe("hidden");
    await expect(dialog.locator(":scope > footer")).toBeInViewport();
  });

  test("keeps a body-only modal accessible and constrained", async ({
    page,
  }) => {
    const section = page.locator("#modal-body-only");
    await section.getByRole("button", { name: "Open body-only modal" }).click();
    const dialog = page.locator("#modal-body-only-dialog");
    const body = dialog.locator(":scope > div");

    await expect(dialog).toHaveAttribute("aria-label", "Project details");
    await expect(dialog.locator(":scope > header")).toHaveCount(0);
    await expect(dialog.locator(":scope > footer")).toHaveCount(0);
    await expect
      .poll(() =>
        body.evaluate((element) => element.scrollHeight > element.clientHeight),
      )
      .toBe(true);
    await expect(body).toHaveCSS("overflow-y", "auto");
    await expect(body.getByRole("button", { name: "Close" })).toBeVisible();
  });

  test("removes modal transitions when reduced motion is requested", async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page
      .locator("#modal-confirmation")
      .getByRole("button", { name: "Delete project" })
      .click();
    const styles = await page
      .locator("#modal-confirmation-dialog")
      .evaluate((element) => ({
        transition: getComputedStyle(element).transitionDuration,
        backdrop: getComputedStyle(element, "::backdrop").transitionDuration,
      }));

    expect(styles.transition).toBe("0s");
    expect(styles.backdrop).toBe("0s");
  });
});
