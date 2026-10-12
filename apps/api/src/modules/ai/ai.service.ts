import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { openaiProvider } from '../../integrations/index.js';
import { aiRepository } from './ai.repository.js';
import type { z } from 'zod';
import type { aiChatSchema, aiEventRefSchema } from './ai.schema.js';

const SYSTEM = `You are Zaya Events' bilingual event planner. Reply in the user's locale (en or ar). Be concrete about venues, vendors, timelines, and budgets in AED.`;

export const aiService = {
  async chat(userId: string, input: z.infer<typeof aiChatSchema>) {
    let context = '';
    if (input.eventId) {
      const event = await aiRepository.event(input.eventId, userId);
      if (!event) {
        throw new NotFoundError('Event not found');
      }
      context = `Event: ${JSON.stringify(event.title)} date=${event.eventDate.toISOString()} guests=${event.guestCount ?? 'n/a'} city=${event.city ?? 'n/a'}`;
    }
    const reply = await openaiProvider.chat([
      { role: 'system', content: `${SYSTEM}\nLocale=${input.locale}\n${context}` },
      ...input.messages,
    ]);
    return { reply };
  },
  async recommendations(userId: string, input: z.infer<typeof aiEventRefSchema>) {
    const event = await aiRepository.event(input.eventId, userId);
    if (!event) {
      throw new ForbiddenError('Event not found');
    }
    const recommendations = await openaiProvider.recommendations(
      `Recommend venues, vendors, and travel ideas for this event. Event=${JSON.stringify(event)}`,
      input.locale,
    );
    return { recommendations };
  },
  async checklist(userId: string, input: z.infer<typeof aiEventRefSchema>) {
    const event = await aiRepository.event(input.eventId, userId);
    if (!event) {
      throw new ForbiddenError('Event not found');
    }
    const checklist = await openaiProvider.checklist(
      `Produce a dated planning checklist for this event. Event=${JSON.stringify(event)}`,
      input.locale,
    );
    return { checklist };
  },
};
