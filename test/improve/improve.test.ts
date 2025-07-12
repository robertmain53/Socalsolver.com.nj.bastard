import { getDiff } from '@/lib/diff'
describe('diff util', () => {
  it('marks additions and removals', () => {
    const d = getDiff('a', 'b')
    expect(d).toContain('[-]a')
    expect(d).toContain('[+]b')
  })
})
