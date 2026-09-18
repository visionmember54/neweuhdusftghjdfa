'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api/client';
import { AdminUser } from '@/lib/api/types';

export function useCurrentAdmin() {
  return useQuery({
    queryKey: ['currentAdmin'],
    queryFn: () => api.get<AdminUser>('/admin/auth/me'),
    retry: false,
  });
}

export function useLogin() {
  const router = useRouter();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (payload: { email: string; password: string }) => {
      const res = await fetch('/api/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Invalid credentials');
      return data.user as AdminUser;
    },
    onSuccess: (user) => {
      queryClient.setQueryData(['currentAdmin'], user);
      router.push('/dashboard');
    },
  });
}

export function useLogout() {
  const router = useRouter();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      await fetch('/api/session', { method: 'DELETE' });
    },
    onSuccess: () => {
      queryClient.clear();
      router.push('/login');
    },
  });
}
