import { test, expect } from "@playwright/test";

test.describe("turbo modal", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/components/modal/turbo");
    await page.waitForSelector("#modal-turbo");
  });

  test("targets the Turbo frame and opens on a matching render", async ({
    page,
  }) => {
    const root = page.locator("#modal-turbo");
    const link = root.getByRole("link", { name: "Edit profile" });
    const dialog = root.locator("dialog");

    await expect(link).toHaveAttribute("data-turbo-frame", "modal");
    await link.click();

    await expect(dialog).toHaveAttribute("open", "");
    await expect(
      dialog.getByRole("heading", { name: "Edit profile" }),
    ).toBeVisible();

    const frame = dialog.locator("turbo-frame");
    await expect(frame.locator(":scope > header")).toBeVisible();
    await expect(frame.locator(":scope > div")).toBeVisible();
    await expect(frame.locator(":scope > footer")).toBeVisible();
    await expect(
      frame.locator(":scope > footer [type='submit']"),
    ).toHaveAttribute("form", "modal-form-fields");
  });

  test("reconnects after the Turbo frame target is replaced", async ({
    page,
  }) => {
    const root = page.locator("#modal-turbo");
    const dialog = root.locator("dialog");
    const frame = root.locator("turbo-frame");
    const frameActions = await frame.getAttribute("data-action");

    const stream = `<turbo-stream action="replace" target="modal">
      <template>
        <turbo-frame id="modal" src="/components/modal/form" data-modal-turbo-target="frame" data-action="${frameActions}"></turbo-frame>
      </template>
    </turbo-stream>`;
    await page.evaluate((message) => {
      if (!window.Turbo?.renderStreamMessage) {
        throw new Error("Turbo.renderStreamMessage is unavailable");
      }
      window.Turbo.renderStreamMessage(message);
    }, stream);

    await expect(dialog).toHaveAttribute("open", "");
    await expect(
      dialog.getByRole("heading", { name: "Edit profile" }),
    ).toBeVisible();
  });

  test.describe("with animations", () => {
    test.use({ animations: "allow" });

    test("keeps frame content during the exit animation", async ({
      page,
    }, testInfo) => {
      test.skip(
        testInfo.project.name !== "desktop",
        "Discrete modal transitions are covered in desktop Chromium.",
      );

      const root = page.locator("#modal-turbo");
      const dialog = root.locator("dialog");
      await root.getByRole("link", { name: "Edit profile" }).click();
      await dialog.getByLabel("Name").fill("Ada");

      const [state] = await Promise.all([
        dialog.evaluate(
          (element) =>
            new Promise((resolve) => {
              element.addEventListener(
                "close",
                () => {
                  requestAnimationFrame(() => {
                    const animations = element
                      .getAnimations({ subtree: true })
                      .map((animation) => ({
                        endTime:
                          animation.effect?.getComputedTiming?.().endTime,
                        pseudoElement: animation.effect?.pseudoElement || null,
                      }));
                    resolve({
                      animations,
                      frameContent:
                        element.querySelector("turbo-frame")?.innerHTML || "",
                    });
                  });
                },
                { once: true },
              );
            }),
        ),
        dialog.getByRole("button", { name: "Save" }).click(),
      ]);

      expect(state.frameContent).not.toBe("");
      expect(state.animations.length).toBeGreaterThan(0);
      expect(
        state.animations.every(({ endTime }) => Number.isFinite(endTime)),
      ).toBe(true);
      expect(
        state.animations.some(
          ({ pseudoElement }) => pseudoElement === "::backdrop",
        ),
      ).toBe(true);
      await expect(dialog).not.toHaveAttribute("open", "");
      await expect(root.locator("turbo-frame")).toBeEmpty();
    });
  });

  test("scrolls structured long content without moving the footer", async ({
    page,
  }) => {
    const root = page.locator("#modal-turbo");
    await root.getByRole("link", { name: "Edit profile" }).click();
    const dialog = root.locator("dialog");
    const frame = dialog.locator("turbo-frame");
    const body = frame.locator(":scope > div");
    const footer = frame.locator(":scope > footer");

    await expect
      .poll(() =>
        body.evaluate((element) => element.scrollHeight > element.clientHeight),
      )
      .toBe(true);
    await body.evaluate((element) =>
      element.scrollTo({ top: element.scrollHeight }),
    );

    await expect
      .poll(() => body.evaluate((element) => element.scrollTop))
      .toBeGreaterThan(0);
    await expect(footer).toBeInViewport();
    await expect(body).toHaveCSS("overflow-y", "auto");
  });

  test("keeps the Turbo modal open after a 422 validation response", async ({
    page,
  }) => {
    const root = page.locator("#modal-turbo");
    await root.getByRole("link", { name: "Edit profile" }).click();
    const dialog = root.locator("dialog");
    await dialog.getByRole("button", { name: "Save" }).click();

    await expect(dialog).toHaveAttribute("open", "");
    await expect(dialog.getByRole("alert")).toHaveText("Name is required");
    await expect(dialog.getByLabel("Name")).toBeFocused();
  });

  test("closes and clears after a successful submission", async ({ page }) => {
    const root = page.locator("#modal-turbo");
    await root.getByRole("link", { name: "Edit profile" }).click();
    const dialog = root.locator("dialog");
    await dialog.getByLabel("Name").fill("Ada");
    await dialog.getByRole("button", { name: "Save" }).click();

    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(root.locator("turbo-frame")).toBeEmpty();
  });

  test("restores a closed and empty modal from the Turbo cache", async ({
    page,
  }) => {
    const root = page.locator("#modal-turbo");
    await root.getByRole("link", { name: "Edit profile" }).click();
    const dialog = root.locator("dialog");
    const frame = root.locator("turbo-frame");
    await expect(dialog).toHaveAttribute("open", "");

    await dialog.getByRole("link", { name: "Cancel" }).click();
    await expect(page).toHaveURL(/\/components\/modal$/);
    await page.goBack();
    await expect(page).toHaveURL(/\/components\/modal\/turbo$/);

    await expect(dialog).not.toHaveAttribute("open", "");
    await expect(frame).toBeEmpty();
  });
});
