// src/app/api/v2/calculators/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

// Validation schema
const CalculatorQuerySchema = z.object({
  category: z.string().optional(),
  featured: z.coerce.boolean().optional(),
  search: z.string().optional(),
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  sort: z.enum(['name', 'category', 'popularity', 'created']).default('name'),
  order: z.enum(['asc', 'desc']).default('asc')
});

export const runtime = 'edge';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);

    const queryData: any = {};
    for (const [key, value] of searchParams.entries()) {
      queryData[key] = value;
    }

    const parsed = CalculatorQuerySchema.safeParse(queryData);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid query', details: parsed.error.flatten() }, { status: 400 });
    }

    const { category, featured, search, page, limit, sort, order } = parsed.data;

    const query: any = {};
    if (category) query.category = category;
    if (featured !== undefined) query.featured = featured;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { 'metadata.tags': { $in: [new RegExp(search, 'i')] } }
      ];
    }

    const skip = (page - 1) * limit;

    const [calculators, total] = await Promise.all([
      getCalculators(query, { skip, limit, sort, order }),
      countCalculators(query)
    ]);

    return NextResponse.json({
      calculators,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
        hasNext: page * limit < total,
        hasPrev: page > 1
      },
      meta: {
        query: parsed.data,
        cached: false
      }
    });
  } catch (err: any) {
    return NextResponse.json(
      { error: 'Failed to fetch calculators', details: err.message },
      { status: 500 }
    );
  }
}

// 🔧 Stub implementations (adapt to your DB layer)
async function getCalculators(query: any, options: any): Promise<any[]> {
  return [];
}

async function countCalculators(query: any): Promise<number> {
  return 0;
}
