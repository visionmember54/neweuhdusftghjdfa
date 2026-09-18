import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';

const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';
const SESSION_COOKIE = process.env.SESSION_COOKIE_NAME || 'kalyan_admin_session';

async function proxy(req: NextRequest, path: string[]): Promise<NextResponse> {
  const token = cookies().get(SESSION_COOKIE)?.value;
  const url = `${BACKEND_URL}/${path.join('/')}${req.nextUrl.search}`;

  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const init: RequestInit = { method: req.method, headers };
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    const body = await req.text();
    if (body) init.body = body;
  }

  const backendResponse = await fetch(url, init);
  const text = await backendResponse.text();

  return new NextResponse(text, {
    status: backendResponse.status,
    headers: { 'Content-Type': backendResponse.headers.get('Content-Type') || 'application/json' },
  });
}

type RouteParams = { params: { path: string[] } };

export async function GET(req: NextRequest, { params }: RouteParams) {
  return proxy(req, params.path);
}
export async function POST(req: NextRequest, { params }: RouteParams) {
  return proxy(req, params.path);
}
export async function PATCH(req: NextRequest, { params }: RouteParams) {
  return proxy(req, params.path);
}
export async function PUT(req: NextRequest, { params }: RouteParams) {
  return proxy(req, params.path);
}
export async function DELETE(req: NextRequest, { params }: RouteParams) {
  return proxy(req, params.path);
}
