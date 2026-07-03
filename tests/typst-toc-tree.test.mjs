import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const article = readFileSync("content/article/a-20260610_vibe_0.typ", "utf8");
const sharedTemplate = readFileSync("typ/templates/shared.typ", "utf8");

test("shared template generates tree table of contents from outline entries", () => {
  assert.match(sharedTemplate, /#let\s+toc-block\b/);
  assert.match(sharedTemplate, /#outline\(/);
  assert.match(sharedTemplate, /#show\s+outline\.entry:/);
  assert.match(sharedTemplate, /query\(heading\.where\(outlined:\s+true\)\)/);
  assert.match(sharedTemplate, /#let\s+tree-prefix\b/);
  assert.match(sharedTemplate, /#let\s+has-next-sibling\b/);
  assert.match(sharedTemplate, /#let\s+ancestor-index\b/);
  assert.doesNotMatch(sharedTemplate, /inset:\s*\(left:\s*calc\.max/);
  assert.doesNotMatch(sharedTemplate, /#let\s+toc-entry-block\b/);

  for (const part of ['"├"', '"└"', '"│  "', '"─►"', '"──"']) {
    assert.ok(sharedTemplate.includes(part), `missing tree branch component ${part}`);
  }
});

test("vibe memo uses the shared default table of contents", () => {
  assert.doesNotMatch(article, /#let\s+vibe-tree-toc\b/);
  assert.doesNotMatch(article, /#vibe-tree-toc\(\)/);
  assert.doesNotMatch(article, /\btoc:\s+false,/);
  assert.doesNotMatch(article, /#let\s+tree-prefix\b/);
  assert.doesNotMatch(article, /query\(heading\.where\(outlined:\s+true\)\)/);
  assert.match(article, /#show:\s+main\.with\(/);
});

test("vibe memo keeps semantic first-level headings without local labels", () => {
  for (const title of ["缘起", "DeepSeek 试验", "Codex 工作流", "总结"]) {
    assert.match(article, new RegExp(`^= ${title}$`, "m"));
  }

  assert.doesNotMatch(article, /^= -1$/m);
  assert.doesNotMatch(article, /^= 0$/m);
  assert.doesNotMatch(article, /^= 1$/m);
  assert.doesNotMatch(article, /^= 2$/m);
});
