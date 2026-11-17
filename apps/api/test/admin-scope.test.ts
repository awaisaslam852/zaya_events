import { recordCountry } from '../src/lib/admin-scope.js';

describe('admin country scope', () => {
  it('follows the vendor desk, not a leftover hall country', () => {
    expect(recordCountry({ country: 'AE', vendor: { country: 'PK' } })).toBe('PK');
    expect(recordCountry({ country: 'AE', vendor: { country: null } })).toBe('AE');
    expect(recordCountry({ country: null, vendor: { country: 'SA' } })).toBe('SA');
  });
});
