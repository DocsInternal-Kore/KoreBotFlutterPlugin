/// Converts Kore Bot text dialect into CommonMark-friendly markdown.
///
/// Native iOS (`TSMarkdownParser`) uses:
/// - `*bold*` for strong
/// - `~italic~` for emphasis
/// - `#h2Heading` for H2
/// - HTML tags that are stripped before markdown render
String normalizeKoreMarkdown(String input) {
  var text = input;

  // Unescape common HTML entities used in bot payloads.
  text = text
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('<br>', '\n')
      .replaceAll('<br/>', '\n')
      .replaceAll('<br />', '\n');

  // Convert simple block/inline HTML to plain text / newlines.
  text = text.replaceAll(
    RegExp(r'</?(p|div|span|section|article)[^>]*>', caseSensitive: false),
    '\n',
  );
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');

  // Kore H2 marker: `#h2Heading text` → `## Heading text`
  text = text.replaceAllMapped(
    RegExp(r'#h2(\S*)', caseSensitive: false),
    (m) {
      final rest = m.group(1) ?? '';
      return rest.isEmpty ? '## ' : '## $rest';
    },
  );

  // Kore italic: `~text~` → `_text_` (avoid touching ~~strike~~).
  text = text.replaceAllMapped(
    RegExp(r'(?<!~)~([^~\n]+)~(?!~)'),
    (m) => '_${m.group(1)}_',
  );

  // Inline triple-backtick spans → single-backtick code
  // (avoids opening an unterminated fenced code block mid-line).
  text = text.replaceAllMapped(
    RegExp(r'```([^`\n]+?)```'),
    (m) => '`${m.group(1)}`',
  );

  // Collapse excessive blank lines from HTML stripping.
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}
