// Build SVG sprite
var req = require.context("../../static/svg", true, /\.svg$/);
req.keys().forEach(req);
