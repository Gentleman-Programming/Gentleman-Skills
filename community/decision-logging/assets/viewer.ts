import { DecisionLogger } from './logger';

async function main() {
  const sessionId = process.argv[2] || 'latest';
  const logger = new DecisionLogger(sessionId);
  
  console.log(`Exporting logs for session ${sessionId}...`);
  const txtPath = await logger.exportToText(sessionId);
  console.log(`TXT: ${txtPath}`);
  const mdPath = await logger.exportToMarkdown(sessionId);
  console.log(`MD: ${mdPath}`);
  
  const isValid = await DecisionLogger.verifyChain(`.gentleman/decisions/${sessionId}.jsonl`);
  console.log(`Chain integrity: ${isValid ? '✅ OK' : '❌ BROKEN'}`);
}

main();
