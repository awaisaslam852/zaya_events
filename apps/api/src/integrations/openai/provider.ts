export type ChatMessage = {
  role: 'system' | 'user' | 'assistant';
  content: string;
};

export type AiRecommendations = {
  venues: Array<{ name: string; reason: string }>;
  vendors: Array<{ name: string; reason: string }>;
  travel: Array<{ name: string; reason: string }>;
};

export type AiChecklistItem = {
  title: string;
  dueOffsetDays: number;
  notes: string;
};

export interface OpenAiProvider {
  chat(messages: ChatMessage[], options?: { model?: string; temperature?: number }): Promise<string>;
  recommendations(prompt: string, locale: 'en' | 'ar'): Promise<AiRecommendations>;
  checklist(prompt: string, locale: 'en' | 'ar'): Promise<AiChecklistItem[]>;
}
