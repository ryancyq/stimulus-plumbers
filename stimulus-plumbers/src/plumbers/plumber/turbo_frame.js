// Excludes events from frames nested in `frame`.
export function isFrameEvent(event, frame) {
  return Boolean(frame) && event.target.closest?.('turbo-frame') === frame;
}

export function isFailedResponse(event) {
  const response = event.detail?.fetchResponse;
  return !response?.succeeded || !response.isHTML;
}
