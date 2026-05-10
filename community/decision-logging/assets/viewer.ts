import { DecisionLogger } from './logger';

const sessionId = process.argv[2] ?? 'session';

async function main() {
  const logger = new DecisionLogger(sessionId);
  const path = `.gentleman/decisions/${sessionId}`;

  const verifyResult = await DecisionLogger.verifyChain(`${path}.jsonl`);
  console.log(`Chain verification: ${verifyResult ? 'OK' : 'BROKEN'}`);

  console.log('Exports:');
  const md = await logger.exportToMarkdown(sessionId);
  console.log(`  Markdown: ${md}`);
  const txt = await logger.exportToText(sessionId);
  console.log(`  TXT: ${txt}`);
}

main().catch(console.error);
