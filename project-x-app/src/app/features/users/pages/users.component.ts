import { Component, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { AuthService } from '../../../core/services/auth.service';
import { SupabaseClientService } from '../../../core/services/supabase-client.service';
import { UserRole, UserStatus } from '../../../core/models';

interface Member {
  id: string;
  user_id: string;
  team_id: string | null;
  role: UserRole;
  status: UserStatus;
  profiles: { full_name: string; email: string } | null;
  teams: { name: string } | null;
}

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [MatButtonModule, MatCardModule, MatFormFieldModule, MatSelectModule, MatTableModule],
  templateUrl: './users.component.html',
  styleUrl: './users.component.scss',
})
export class UsersComponent {
  private readonly auth = inject(AuthService);
  private readonly supabase = inject(SupabaseClientService).client;

  readonly members = signal<Member[]>([]);
  readonly loading = signal(true);
  readonly errorMessage = signal<string | null>(null);
  readonly displayedColumns = ['name', 'email', 'team', 'role', 'status', 'actions'];

  constructor() { void this.loadMembers(); }

  async loadMembers(): Promise<void> {
    const organizationId = this.auth.profile()?.organization_id;
    if (!organizationId) { this.loading.set(false); return; }
    const { data, error } = await this.supabase
      .from('organization_members')
      .select('id, user_id, team_id, role, status, profiles!inner(full_name, email), teams(name)')
      .eq('organization_id', organizationId)
      .order('created_at');
    this.loading.set(false);
    if (error) { this.errorMessage.set(error.message); return; }
    this.members.set((data ?? []) as unknown as Member[]);
  }

  async updateMember(member: Member, field: 'role' | 'status', value: UserRole | UserStatus): Promise<void> {
    const { error } = await this.supabase.from('organization_members').update({ [field]: value }).eq('id', member.id);
    if (error) { this.errorMessage.set(error.message); return; }
    await this.loadMembers();
  }
}