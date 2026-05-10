import fs from 'fs/promises';
import crypto from 'crypto';

interface DecisionEvent {
  id: string;
  sessionId: string;
  timestamp: string;
  agent: string;
  category: DecisionCategory;
  input: {
    context: Record<string, unknown>;
    alternatives: string[];
  };
  decision: {
    chosen: string;
    reasoning: string;
    confidence: number;
  };
  outcome?: string;
  hash?: string;
  prevHash?: string;
}

type DecisionCategory = 
  | 'architecture'
  | 'implementation'
  | 'tooling'
  | 'security'
  | 'performance'
  | 'correctness';

export class DecisionLogger {
  private filePath: string;
  private lastHash: string = '';

  constructor(sessionId: string) {
    this.filePath = `.gentleman/decisions/${sessionId}.jsonl`;
    this.ensureDir();
  }

  private async ensureDir() {
    await fs.mkdir('.gentleman/decisions', { recursive: true });
  }

  private sha256(data: string): string {
    return crypto.createHash('sha256').update(data).digest('hex');
  }

  async log(event: DecisionEvent): Promise<void> {
    const hash = this.sha256(JSON.stringify(event));
    const record = { ...event, hash, prevHash: this.lastHash };
    await fs.appendFile(this.filePath, JSON.stringify(record) + '\n');
    this.lastHash = hash;
  }

  private async readEntries(): Promise<DecisionEvent[]> {
    try {
      const data = await fs.readFile(this.filePath, 'utf8');
      return data.split('\n').filter(Boolean).map(line => JSON.parse(line));
    } catch {
      return [];
    }
  }

  async exportToText(sessionId: string): Promise<string> {
    const entries = await this.readEntries();
    let text = `Decision Log – Session ${sessionId}\n`;
    text += `Generated: ${new Date().toISOString()}\n\n`;
    for (const e of entries) {
      text += `[${e.timestamp}] ${e.category.toUpperCase()}: ${e.decision.chosen}\n`;
      text += `Reasoning: ${e.decision.reasoning}\n`;
      if (e.outcome) text += `Outcome: ${e.outcome}\n`;
      text += `---\n`;
    }
    const outputPath = `.gentleman/decisions/${sessionId}.txt`;
    await fs.writeFile(outputPath, text);
    return outputPath;
  }

  async exportToMarkdown(sessionId: string): Promise<string> {
    const entries = await this.readEntries();
    let md = `# Decision Log – Session ${sessionId}\n\n`;
    md += `**Generated:** ${new Date().toISOString()}\n\n`;
    md += `| Timestamp | Category | Decision | Reasoning |\n`;
    md += `|-----------|----------|----------|------------|\n`;
    for (const e of entries) {
      md += `| ${e.timestamp} | ${e.category} | ${e.decision.chosen} | ${e.decision.reasoning} |\n`;
    }
    const outputPath = `.gentleman/decisions/${sessionId}.md`;
    await fs.writeFile(outputPath, md);
    return outputPath;
  }

  static async verifyChain(filePath: string): Promise<boolean> {
    const data = await fs.readFile(filePath, 'utf8');
    const entries = data.split('\n').filter(Boolean).map(line => JSON.parse(line));
    let previousHash = '';
    for (const entry of entries) {
      if (entry.prevHash !== previousHash) return false;
      previousHash = entry.hash;
    }
    return true;
  }
}
