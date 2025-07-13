import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
export const runtime='edge'
const Schema=z.object({category:z.string().optional(),featured:z.coerce.boolean().optional(),search:z.string().optional(),page:z.coerce.number().min(1).default(1),limit:z.coerce.number().min(1).max(100).default(20),sort:z.enum(['name','category','popularity','created']).default('name'),order:z.enum(['asc','desc']).default('asc')})
export async function GET(req:NextRequest){
 const url=new URL(req.url);const raw=Object.fromEntries(url.searchParams.entries())
 const parsed=Schema.safeParse(raw);if(!parsed.success) return NextResponse.json({error:'Invalid query',details:parsed.error.flatten()},{status:400})
 const {page,limit}=parsed.data
 return NextResponse.json({calculators:[],pagination:{page,limit,total:0,pages:0,hasNext:false,hasPrev:false}})
}
