# Repository Notes For Agents

- For Overpy arrays, `array.append(otherArray)` may merge elements instead of adding `otherArray` as a nested item.
- To store one nested spot/settings array as a single element, assign by index:
  `debugBallisticsSpots[len(debugBallisticsSpots)] = eventPlayer.tmp0`
- Overpy/Workshop compiler may block variable or subroutine names if they contain censored substrings (for example, `...hit...` contains `...shit...`).
- Avoid such names and use neutral alternatives (for example, `impactPos` instead of `hitPos`).
