import type { AiChecklistItem, AiRecommendations, ChatMessage, OpenAiProvider } from './provider.js';

export class MockOpenAiProvider implements OpenAiProvider {
  async chat(messages: ChatMessage[]): Promise<string> {
    const last = [...messages].reverse().find((item) => item.role === 'user')?.content ?? '';
    const localeHint = messages[0]?.content.includes('Locale=ar') ? 'ar' : 'en';
    if (localeHint === 'ar') {
      return `خطة مبدئية (محاكاة): ركّزي على قاعة في دبي، منسّق ورود، وتصوير. طلبك: ${last.slice(0, 180)}`;
    }
    return `Mock planner: lock a Dubai venue 12 months out, then florist + photography. You asked: ${last.slice(0, 180)}`;
  }

  async recommendations(_prompt: string, locale: 'en' | 'ar'): Promise<AiRecommendations> {
    if (locale === 'ar') {
      return {
        venues: [{ name: 'قصر الإمارات', reason: 'سعة كبيرة وإطلالة رسمية' }],
        vendors: [{ name: 'مصور زايا', reason: 'تغطية يوم كامل بالعربية والإنجليزية' }],
        travel: [{ name: 'مالديف 5 ليالٍ', reason: 'شهر عسل بعد المناسبة' }],
      };
    }
    return {
      venues: [{ name: 'Emirates Palace', reason: 'Formal capacity and on-site suites' }],
      vendors: [{ name: 'Zaya Studio', reason: 'Bilingual full-day coverage' }],
      travel: [{ name: 'Maldives 5 nights', reason: 'Post-event honeymoon buffer' }],
    };
  }

  async checklist(_prompt: string, locale: 'en' | 'ar'): Promise<AiChecklistItem[]> {
    if (locale === 'ar') {
      return [
        { title: 'حجز القاعة', dueOffsetDays: -365, notes: 'ادفعي العربون واحصلي على العقد.' },
        { title: 'تأكيد قائمة الضيوف', dueOffsetDays: -60, notes: 'أرسلي الأسماء للمنسّق الأمني.' },
        { title: 'تجربة الطعام', dueOffsetDays: -30, notes: 'اختاري القائمة النهائية.' },
      ];
    }
    return [
      { title: 'Hold the venue', dueOffsetDays: -365, notes: 'Pay the deposit and file the contract.' },
      { title: 'Lock guest list', dueOffsetDays: -60, notes: 'Send names for security.' },
      { title: 'Tasting', dueOffsetDays: -30, notes: 'Confirm the final menu.' },
    ];
  }
}
