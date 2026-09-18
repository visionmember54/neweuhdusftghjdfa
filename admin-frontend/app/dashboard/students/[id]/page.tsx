'use client';

import Link from 'next/link';
import { useParams } from 'next/navigation';
import PageHeader from '@/components/layout/PageHeader';
import { Card, CardBody, CardHeader, CardTitle } from '@/components/ui/Card';
import { StatusBadge } from '@/components/ui/Badge';
import { LoadingState, ErrorState, EmptyState } from '@/components/ui/States';
import { Table, TBody, Td, Th, THead, Tr } from '@/components/ui/Table';
import { useStudent } from '@/hooks/useStudents';
import { useCreditHistory } from '@/hooks/useCredits';
import { useSimulations } from '@/hooks/useSimulations';
import { useAuditLogs } from '@/hooks/useAuditLogs';

export default function StudentDetailPage() {
  const params = useParams<{ id: string }>();
  const studentId = Number(params.id);
  const student = useStudent(studentId);
  const credits = useCreditHistory(studentId, { limit: 10 });
  const simulations = useSimulations({ studentId, limit: 10 });
  const audit = useAuditLogs({ userId: studentId, limit: 10 });

  if (student.isLoading) return <LoadingState />;
  if (student.isError) return <ErrorState message={(student.error as Error).message} />;
  if (!student.data) return <EmptyState title="User not found" />;
  const user = student.data;

  return <div>
    <PageHeader icon="users" title={user.name} description="User profile, virtual-credit ledger, simulation activity, and administrative history." action={<Link href={`/dashboard/wallet-activity/credits?studentId=${user.id}`} className="inline-flex items-center justify-center gap-1.5 rounded-lg bg-gradient-to-b from-brand-500 to-brand-600 px-4 py-2 text-sm font-semibold text-white shadow-glow transition-all hover:from-brand-400 hover:to-brand-500 active:scale-[0.98]">Manage Credits</Link>} />
    <Card className="mb-6"><CardBody><div className="grid grid-cols-2 gap-4 text-sm md:grid-cols-5"><div><p className="text-xs text-slate-500">Phone</p><p>{user.phone}</p></div><div><p className="text-xs text-slate-500">Email</p><p>{user.email || '—'}</p></div><div><p className="text-xs text-slate-500">Status</p><StatusBadge status={user.status} /></div><div><p className="text-xs text-slate-500">Balance</p><p className="font-bold">{user.balance.toLocaleString()} credits</p></div><div><p className="text-xs text-slate-500">User ID</p><p>#{user.id}</p></div></div></CardBody></Card>
    <div className="grid gap-6 xl:grid-cols-2">
      <Card><CardHeader><CardTitle>Credit History</CardTitle></CardHeader><CardBody>{credits.isLoading ? <LoadingState /> : credits.data?.items.length ? <Table><THead><Tr><Th>Type</Th><Th>Amount</Th><Th>Balance</Th><Th>Note</Th></Tr></THead><TBody>{credits.data.items.map((entry) => <Tr key={entry.id}><Td>{entry.type}</Td><Td className={entry.amount >= 0 ? 'text-emerald-600' : 'text-red-600'}>{entry.amount}</Td><Td>{entry.balanceAfter}</Td><Td>{entry.note ?? '—'}</Td></Tr>)}</TBody></Table> : <EmptyState title="No credit activity" />}</CardBody></Card>
      <Card><CardHeader><CardTitle>Recent Simulations</CardTitle></CardHeader><CardBody>{simulations.isLoading ? <LoadingState /> : simulations.data?.items.length ? <Table><THead><Tr><Th>Game</Th><Th>Selection</Th><Th>Credits</Th><Th>Status</Th></Tr></THead><TBody>{simulations.data.items.map((entry) => <Tr key={entry.id}><Td>{entry.gameType}</Td><Td>{entry.selection}</Td><Td>{entry.simulatedCredits}</Td><Td><StatusBadge status={entry.status} /></Td></Tr>)}</TBody></Table> : <EmptyState title="No simulations yet" />}</CardBody></Card>
    </div>
    <Card className="mt-6"><CardHeader><CardTitle subtitle="Newly recorded user-related administrative changes">Admin Activity</CardTitle></CardHeader><CardBody>{audit.isLoading ? <LoadingState /> : audit.data?.items.length ? <ul className="space-y-2 text-sm">{audit.data.items.map((entry) => <li key={entry.id}><span className="font-semibold">{entry.actor}</span> {entry.details} <span className="text-xs text-slate-400">{entry.createdAt}</span></li>)}</ul> : <EmptyState title="No user-specific admin activity yet" />}</CardBody></Card>
  </div>;
}
