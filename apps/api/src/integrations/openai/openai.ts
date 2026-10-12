import OpenAI from 'openai';
import { integrationsConfig } from '../config.js';
import { missingCredentials } from '../credentials.js';
import { AppError } from '../../lib/errors.js';
import type { AiChecklistItem, AiRecommendations, ChatMessage, OpenAiProvider } from './provider.js';

export class RealOpenAiProvider implements OpenAiProvider {
  private client: OpenAI | undefined;

  constructor() {
    if (!integrationsConfig.OPENAI_API_KEY) {
      missingCredentials('openai', ['OPENAI_API_KEY']);
    }
  }

  private openai(): OpenAI {
    this.client ??= new OpenAI({ apiKey: integrationsConfig.OPENAI_API_KEY });
    return this.client;
  }

  async chat(messages: ChatMessage[], options?: { model?: string; temperature?: number }): Promise<string> {
    const completion = await this.openai().chat.completions.create({
      model: options?.model ?? integrationsConfig.OPENAI_MODEL,
      messages,
      temperature: options?.temperature ?? 0.4,
    });
    const content = completion.choices[0]?.message.content;
    if (!content) {
      throw new AppError(502, 'OPENAI_EMPTY', 'OpenAI returned an empty response');
    }
    return content;
  }

  async recommendations(prompt: string, locale: 'en' | 'ar'): Promise<AiRecommendations> {
    // TODO: switch to structured outputs / json_schema for venues, vendors, travel
    const raw = await this.chat(
      [
        {
          role: 'system',
          content: `Return JSON keys venues, vendors, travel. Each is [{name, reason}]. Locale=${locale}.`,
        },
        { role: 'user', content: prompt },
      ],
      { temperature: 0.3 },
    );
    try {
      return JSON.parse(raw) as AiRecommendations;
    } catch {
      return {
        venues: [{ name: 'See planner reply', reason: raw.slice(0, 240) }],
        vendors: [],
        travel: [],
      };
    }
  }

  async checklist(prompt: string, locale: 'en' | 'ar'): Promise<AiChecklistItem[]> {
    // TODO: json_schema array of {title, dueOffsetDays, notes}
    const raw = await this.chat(
      [
        {
          role: 'system',
          content: `Return JSON array of {title, dueOffsetDays, notes}. Locale=${locale}.`,
        },
        { role: 'user', content: prompt },
      ],
      { temperature: 0.2 },
    );
    try {
      const parsed = JSON.parse(raw) as AiChecklistItem[];
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [{ title: raw.slice(0, 80), dueOffsetDays: -30, notes: raw.slice(0, 240) }];
    }
  }
}
