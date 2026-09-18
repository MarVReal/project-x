import { Injectable, computed, inject } from '@angular/core';
import { AuthService } from './auth.service';
import { UserRole } from '../models';

// Single source of truth for role-based authorization on the client.
// This is a UX convenience only — Supabase RLS is the real enforcement boundary (see supabase/migrations).
@Injectable({ providedIn: 'root' })
export class PermissionService {
  private readonly auth = inject(AuthService);

  readonly role = computed<UserRole | null>(() => this.auth.profile()?.role ?? null);

  readonly isAdmin = computed(() => this.role() === 'admin');
  readonly isSectionHead = computed(() => this.role() === 'section_head');
  readonly isStaff = computed(() => this.role() === 'staff');

  hasRole(...roles: UserRole[]): boolean {
    const current = this.role();
    return current !== null && roles.includes(current);
  }

  canManageUsers(): boolean {
    return this.isAdmin();
  }

  canManagePipelines(): boolean {
    return this.isAdmin();
  }

  canManageStages(): boolean {
    return this.isAdmin();
  }

  canManageTags(): boolean {
    return this.isAdmin();
  }

  canManageOrganizationSettings(): boolean {
    return this.isAdmin();
  }

  canViewAllTasks(): boolean {
    return this.isAdmin();
  }

  canViewAdminDashboard(): boolean {
    return this.isAdmin();
  }

  canViewSectionDashboard(): boolean {
    return this.isAdmin() || this.isSectionHead();
  }

  canAssignTasks(): boolean {
    return this.isAdmin() || this.isSectionHead();
  }
}
