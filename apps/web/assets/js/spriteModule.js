/*
 * from https://github.com/kisenka/svg-sprite-loader/blob/v4.1.6/runtime/browser-sprite.js
 *
 * customized to mount to existing dom prepared by elm instead of to body
 * required to avoid crashing elm virtual dom
 */

import BrowserSprite from "svg-baker-runtime/src/browser-sprite";
import domready from "domready";

const spriteNodeId = "__SVG_SPRITE_NODE__";
const spriteGlobalVarName = "__SVG_SPRITE__";
const isSpriteExists = !!window[spriteGlobalVarName];

// eslint-disable-next-line import/no-mutable-exports
let sprite;

if (isSpriteExists) {
  sprite = window[spriteGlobalVarName];
} else {
  sprite = new BrowserSprite({ attrs: { id: spriteNodeId } });
  window[spriteGlobalVarName] = sprite;
}

const loadSprite = () => {
  /**
   * Check for page already contains sprite node
   * If found - attach to and reuse it's content
   * If not - render and mount the new sprite
   */
  const existing = document.getElementById(spriteNodeId);

  if (existing) {
    sprite.attach(existing);
  } else {
    sprite.mount("#svg-root");
  }
};

if (document.body) {
  loadSprite();
} else {
  domready(loadSprite);
}

export default sprite;
